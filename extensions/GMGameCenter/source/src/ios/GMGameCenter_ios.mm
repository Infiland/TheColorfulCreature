
#import "GMGameCenter_ios.h"

#import "core/GMExtWire.h"

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "TargetConditionals.h"

#include <cstdint>
#include <mutex>
#include <stdexcept>
#include <string>
#include <string_view>
#include <utility>
#include <vector>

#if !TARGET_OS_OSX
extern UIViewController *g_controller;
#else
extern NSViewController *g_controller;
static NSWindow *g_game_center_window = nil;
#endif

static NSString *NSStringFromStringView(std::string_view value)
{
    NSString *result = [[NSString alloc] initWithBytes:value.data()
                                                length:value.size()
                                              encoding:NSUTF8StringEncoding];
    return result != nil ? result : @"";
}

static std::string StringFromNSString(NSString *value)
{
    if (value == nil) return std::string();
    const char *utf8 = value.UTF8String;
    return utf8 != nullptr ? std::string(utf8) : std::string();
}

static std::string ErrorMessage(NSError *error)
{
    if (error == nil) return std::string();
    NSString *message = error.localizedDescription;
    if (message == nil || message.length == 0) message = error.description;
    return StringFromNSString(message);
}

static double DateToGMDate(NSDate *date)
{
    if (date == nil) return -1.0;
    return ((((double)[date timeIntervalSince1970]) + 0.5) / 86400.0) + 25569.0;
}

// Fills the common success/error fields shared by every result struct. Works on
// any gm_structs type that exposes `success`, `error_code` and `error_message`.
template <typename T>
static void GCFillError(T &out, NSError *error)
{
    out.success = (error == nil);
    out.error_code = static_cast<std::int32_t>(error != nil ? error.code : 0);
    out.error_message = ErrorMessage(error);
}

// GKGameCenterControllerDelegate is deprecated as of iOS/macOS 26.0 (whole protocol, alongside
// GKGameCenterViewController). Kept because gamecenter_present_view_achievement/_leaderboard (per-ID
// deep-links) have no GKAccessPoint equivalent as of iOS 26; revisit if Apple ships one.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
@interface GMGameCenter () <GKLocalPlayerListener, GKGameCenterControllerDelegate>
#pragma clang diagnostic pop
@property(nonatomic, assign) gm::wire::GMFunction viewCallback;
@property(nonatomic, assign) gm::wire::GMFunction savedGamesEventCallback;
@property(nonatomic, assign) gm::wire::GMFunction authenticateCallback;
@property(nonatomic, strong) NSMutableDictionary<NSNumber *, NSArray<GKSavedGame *> *> *conflictGroups;
@property(nonatomic, strong) NSMutableDictionary<NSNumber *, NSData *> *heldSavedGameData;
@end

@implementation GMGameCenter {
    // Guards all callback properties and data dictionaries, which are touched both from
    // the game thread (extension entry points) and from GameKit listener/delegate callbacks. Apple
    // does not guarantee those callbacks arrive on the main thread, so this is required, not just
    // defensive. Callbacks are copied out under the lock and fired outside it (the GML dispatch is
    // itself thread-safe) to avoid holding the lock across a callback.
    std::mutex _stateMutex;
    NSInteger _nextConflictId;
    NSInteger _nextDataHandleId;
    BOOL _authenticateHandlerSet;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.conflictGroups = [NSMutableDictionary dictionary];
        self.heldSavedGameData = [NSMutableDictionary dictionary];
        _nextDataHandleId = 1;
        _authenticateHandlerSet = NO;
        [[GKLocalPlayer localPlayer] registerListener:self];
        [self setupAuthenticationHandler];
    }
    return self;
}

- (void)dealloc
{
    [[GKLocalPlayer localPlayer] unregisterListener:self];
    self.conflictGroups = nil;
    self.heldSavedGameData = nil;
}

- (void)setupAuthenticationHandler
{
    if (_authenticateHandlerSet) return;
    _authenticateHandlerSet = YES;

    [GKLocalPlayer localPlayer].authenticateHandler = ^(
#if !TARGET_OS_OSX
        UIViewController *viewController,
#else
        NSViewController *viewController,
#endif
        NSError *error)
    {
        GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
        std::string state = "unknown";

        if (viewController != nil) {
#if !TARGET_OS_OSX
            [g_controller presentViewController:viewController animated:YES completion:nil];
#else
            [[GKDialogController sharedDialogController]
                presentViewController:(NSViewController<GKViewController> *)viewController];
#endif
            state = "presenting_view";
        } else if (localPlayer.isAuthenticated) {
            state = "authenticated";
        }

        gm::wire::GMFunction callback;
        {
            std::lock_guard<std::mutex> lock(_stateMutex);
            callback = self.authenticateCallback;
        }

        if (callback) {
            gm_structs::GameCenterAuthResult result{};
            GCFillError(result, error);
            result.authentication_state = state;
            result.authenticated = (localPlayer.isAuthenticated == YES);
            result.player = [self playerStructFor:localPlayer];
            callback.call(result);
        }
    };
}

#pragma mark - Struct helpers

- (gm_structs::GameCenterPlayer)playerStructFor:(GKPlayer *)player
{
    gm_structs::GameCenterPlayer out{};
    if (player == nil) return out;

    out.alias = StringFromNSString(player.alias);
    out.display_name = StringFromNSString(player.displayName);
    out.player_id = StringFromNSString(player.gamePlayerID);
    out.game_player_id = StringFromNSString(player.gamePlayerID);
    out.team_player_id = StringFromNSString(player.teamPlayerID);

    return out;
}

- (gm_structs::GameCenterSavedGame)savedGameStructFor:(GKSavedGame *)savedGame
{
    gm_structs::GameCenterSavedGame out{};
    if (savedGame == nil) return out;

    out.device_name = StringFromNSString(savedGame.deviceName);
    out.modification_date = DateToGMDate(savedGame.modificationDate);
    out.name = StringFromNSString(savedGame.name);
    return out;
}

- (gm_structs::GameCenterLeaderboardEntry)leaderboardEntryStructFor:(GKLeaderboardEntry *)entry
{
    gm_structs::GameCenterLeaderboardEntry out{};
    if (entry == nil) {
        out.rank = -1; // sentinel: this player has no entry in the requested range
        return out;
    }

    out.context = static_cast<double>(entry.context);
    out.date = DateToGMDate(entry.date);
    out.rank = static_cast<double>(entry.rank);
    out.score = static_cast<double>(entry.score);
    out.formatted_score = StringFromNSString(entry.formattedScore);
    out.player = [self playerStructFor:entry.player];
    return out;
}

- (gm_structs::GameCenterAchievement)achievementStructFor:(GKAchievement *)achievement
{
    gm_structs::GameCenterAchievement out{};
    if (achievement == nil) return out;

    out.identifier = StringFromNSString(achievement.identifier);
    out.percent_complete = achievement.percentComplete;
    out.is_completed = (achievement.isCompleted == YES);
    out.shows_completion_banner = (achievement.showsCompletionBanner == YES);
    out.player = [self playerStructFor:achievement.player];
    out.last_reported_date = DateToGMDate(achievement.lastReportedDate);
    return out;
}

#pragma mark - View presentation

- (void)gamecenter_view_callback_subscribe:(gm::wire::GMFunction)callback
{
    std::lock_guard<std::mutex> lock(_stateMutex);
    self.viewCallback = callback;
}

// GKGameCenterViewController is deprecated as of iOS/macOS 26.0 (whole class). presentController:,
// gamecenter_present_view_achievement/_leaderboard, and the dismiss delegate below all still need it:
// GKAccessPoint has no equivalent for presenting a specific achievement/leaderboard by ID, so those two
// functions are kept deprecated-but-functional; revisit if Apple ships a replacement.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (bool)presentController:(GKGameCenterViewController *)controller
{
    if (controller == nil) return false;
    controller.gameCenterDelegate = self;
#if !TARGET_OS_OSX
    [g_controller presentViewController:controller animated:YES completion:nil];
#else
    [[GKDialogController sharedDialogController] presentViewController:controller];
#endif
    return true;
}

- (bool)gamecenter_present_view_achievement:(std::string_view)achievement_id
{
    if (@available(iOS 14.0, macOS 11.0, *)) {
        GKGameCenterViewController *controller = [[GKGameCenterViewController alloc]
            initWithAchievementID:NSStringFromStringView(achievement_id)];
        return [self presentController:controller];
    }
    return false;
}

- (bool)gamecenter_present_view_leaderboard:(std::string_view)leaderboard_id
                                  time_scope:(gm_enums::GameCenterLeaderboardTimeScope)time_scope
                                player_scope:(gm_enums::GameCenterLeaderboardPlayerScope)player_scope
{
    GKLeaderboardTimeScope ts = static_cast<GKLeaderboardTimeScope>(time_scope);
    GKLeaderboardPlayerScope ps = static_cast<GKLeaderboardPlayerScope>(player_scope);

    GKGameCenterViewController *controller = [[GKGameCenterViewController alloc]
        initWithLeaderboardID:NSStringFromStringView(leaderboard_id)
                   playerScope:ps
                     timeScope:ts];
    return [self presentController:controller];
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)controller
{
#if !TARGET_OS_OSX
    if (controller != nil) [g_controller dismissViewControllerAnimated:YES completion:nil];
#else
    if (controller != nil) [[GKDialogController sharedDialogController] dismiss:self];
#endif

    gm::wire::GMFunction viewCallback;
    {
        std::lock_guard<std::mutex> lock(_stateMutex);
        viewCallback = self.viewCallback;
    }
    if (viewCallback) {
        viewCallback.call();
    }
}
#pragma clang diagnostic pop

#pragma mark - Local player

- (void)gamecenter_local_player_authenticate:(gm::wire::GMFunction)callback
{
    std::lock_guard<std::mutex> lock(_stateMutex);
    self.authenticateCallback = callback;
}

- (bool)gamecenter_local_player_is_authenticated { return [GKLocalPlayer localPlayer].isAuthenticated == YES; }
- (bool)gamecenter_local_player_is_underage { return [GKLocalPlayer localPlayer].isUnderage == YES; }

- (bool)gamecenter_local_player_is_multiplayer_gaming_restricted
{
    if (@available(iOS 13.0, macOS 10.15, *)) {
        return [GKLocalPlayer localPlayer].isMultiplayerGamingRestricted == YES;
    }
    return false;
}

- (bool)gamecenter_local_player_is_personalized_communication_restricted
{
    if (@available(iOS 14.0, macOS 11.0, *)) {
        return [GKLocalPlayer localPlayer].isPersonalizedCommunicationRestricted == YES;
    }
    return false;
}

- (gm_structs::GameCenterPlayer)gamecenter_local_player_get_info
{
    return [self playerStructFor:[GKLocalPlayer localPlayer]];
}

#pragma mark - Saved games

- (void)gamecenter_saved_games_callback_subscribe:(gm::wire::GMFunction)callback
{
    std::lock_guard<std::mutex> lock(_stateMutex);
    self.savedGamesEventCallback = callback;
}

- (void)gamecenter_saved_games_fetch:(gm::wire::GMFunction)callback
{
    [[GKLocalPlayer localPlayer] fetchSavedGamesWithCompletionHandler:^(NSArray<GKSavedGame *> *savedGames, NSError *error) {
        std::vector<gm_structs::GameCenterSavedGame> slots;
        for (GKSavedGame *savedGame in savedGames ?: @[]) slots.push_back([self savedGameStructFor:savedGame]);

        gm_structs::GameCenterSavedGamesFetchResult result{};
        GCFillError(result, error);
        result.slots = std::move(slots);
        callback.call(result);
    }];
}

- (void)gamecenter_saved_games_save:(std::string_view)name
                                data:(gm::wire::GMBuffer)buffer
                            callback:(gm::wire::GMFunction)callback
{
    NSString *saveName = NSStringFromStringView(name);

    // Read the exact number of bytes backing the GML buffer.
    std::size_t len = static_cast<std::size_t>(buffer.length());
    std::vector<char> raw(len);

    try {
        auto reader = buffer.getReader();
        if (len > 0) {
            reader.readBytes(raw.data(), len);
        }
    } catch (const std::exception &ex) {
        gm_structs::GameCenterSavedGamesSaveResult result{};
        result.success = false;
        result.error_code = 0;
        result.error_message = "Failed to read buffer data.";
        result.name = StringFromNSString(saveName);
        callback.call(result);
        return;
    }

    NSData *saveData = [NSData dataWithBytes:raw.data() length:len];

    [[GKLocalPlayer localPlayer] saveGameData:saveData withName:saveName completionHandler:^(GKSavedGame *savedGame, NSError *error) {
        gm_structs::GameCenterSavedGamesSaveResult result{};
        GCFillError(result, error);
        result.name = StringFromNSString(saveName);
        result.slot = [self savedGameStructFor:savedGame];
        callback.call(result);
    }];
}

- (void)gamecenter_saved_games_delete:(std::string_view)name
                             callback:(gm::wire::GMFunction)callback
{
    NSString *saveName = NSStringFromStringView(name);
    [[GKLocalPlayer localPlayer] deleteSavedGamesWithName:saveName completionHandler:^(NSError *error) {
        gm_structs::GameCenterSavedGamesDeleteResult result{};
        GCFillError(result, error);
        result.name = StringFromNSString(saveName);
        callback.call(result);
    }];
}

- (void)gamecenter_saved_games_data_request:(std::string_view)name
                                    callback:(gm::wire::GMFunction)callback
{
    NSString *saveName = NSStringFromStringView(name);
    [[GKLocalPlayer localPlayer] fetchSavedGamesWithCompletionHandler:^(NSArray<GKSavedGame *> *savedGames, NSError *fetchError) {
        if (fetchError != nil) {
            gm_structs::GameCenterSavedGamesDataResult result{};
            GCFillError(result, fetchError);
            result.name = StringFromNSString(saveName);
            result.handle_id = -1;
            result.required_size = 0;
            callback.call(result);
            return;
        }

        GKSavedGame *match = nil;
        for (GKSavedGame *savedGame in savedGames ?: @[]) {
            if (![savedGame.name isEqualToString:saveName]) continue;
            if (match == nil ||
                [savedGame.modificationDate compare:match.modificationDate] == NSOrderedDescending) {
                match = savedGame;
            }
        }

        if (match == nil) {
            gm_structs::GameCenterSavedGamesDataResult result{};
            result.success = false;
            result.name = StringFromNSString(saveName);
            result.handle_id = -1;
            result.required_size = 0;
            result.error_code = 0;
            result.error_message = "Saved game was not found.";
            callback.call(result);
            return;
        }

        [match loadDataWithCompletionHandler:^(NSData *loadedData, NSError *loadError) {
            gm_structs::GameCenterSavedGamesDataResult result{};
            GCFillError(result, loadError);
            result.name = StringFromNSString(saveName);

            if (loadError == nil && loadedData != nil) {
                NSInteger handleId = 0;
                {
                    std::lock_guard<std::mutex> lock(_stateMutex);
                    handleId = _nextDataHandleId++;
                    self.heldSavedGameData[@(handleId)] = loadedData;
                }
                result.handle_id = static_cast<std::int32_t>(handleId);
                result.required_size = static_cast<double>(loadedData.length);
            } else {
                result.handle_id = -1;
                result.required_size = 0;
            }

            callback.call(result);
        }];
    }];
}

- (bool)gamecenter_saved_games_data_fetch:(double)handle_id
                                      data:(gm::wire::GMBuffer)buffer
{
    NSInteger hId = static_cast<NSInteger>(handle_id);
    NSData *data = nil;
    {
        std::lock_guard<std::mutex> lock(_stateMutex);
        data = self.heldSavedGameData[@(hId)];
    }

    if (data == nil) return false;
    // Keep the hold if the copy can't complete, so the caller can retry with a correctly-sized
    // buffer instead of losing the data (required_size was reported precisely so it can be sized).
    if (buffer.length() < static_cast<std::uint64_t>(data.length)) return false;

    // Write the saved data into the provided buffer
    try {
        auto writer = buffer.getWriter();
        writer.writeBytes(data.bytes, static_cast<std::size_t>(data.length));
    } catch (const std::exception &ex) {
        return false;
    }

    // Copy succeeded: release the native-side hold.
    {
        std::lock_guard<std::mutex> lock(_stateMutex);
        [self.heldSavedGameData removeObjectForKey:@(hId)];
    }
    return true;
}

- (bool)gamecenter_saved_games_data_release:(double)handle_id
{
    NSInteger hId = static_cast<NSInteger>(handle_id);
    std::lock_guard<std::mutex> lock(_stateMutex);
    if (self.heldSavedGameData[@(hId)] == nil) return false;

    [self.heldSavedGameData removeObjectForKey:@(hId)];
    return true;
}

- (void)gamecenter_saved_games_resolve_conflict:(double)conflict_id
                                           data:(gm::wire::GMBuffer)buffer
                                       callback:(gm::wire::GMFunction)callback
{
    NSInteger conflictId = (NSInteger)conflict_id;
    NSArray<GKSavedGame *> *conflicts = nil;
    {
        std::lock_guard<std::mutex> lock(_stateMutex);
        conflicts = self.conflictGroups[@(conflictId)];
    }

    if (conflicts == nil) {
        gm_structs::GameCenterSavedGamesResolveResult result{};
        result.success = false;
        result.conflict_id = static_cast<std::int32_t>(conflictId);
        result.error_code = 0;
        result.error_message = "Invalid conflict ID.";
        callback.call(result);
        return;
    }

    // Read the exact number of bytes backing the GML buffer.
    std::size_t len = static_cast<std::size_t>(buffer.length());
    std::vector<char> raw(len);

    try {
        auto reader = buffer.getReader();
        if (len > 0) {
            reader.readBytes(raw.data(), len);
        }
    } catch (const std::exception &ex) {
        gm_structs::GameCenterSavedGamesResolveResult result{};
        result.success = false;
        result.conflict_id = static_cast<std::int32_t>(conflictId);
        result.error_code = 0;
        result.error_message = "Failed to read buffer data.";
        callback.call(result);
        return;
    }

    NSData *resolvedData = [NSData dataWithBytes:raw.data() length:len];

    [[GKLocalPlayer localPlayer] resolveConflictingSavedGames:conflicts
                                                    withData:resolvedData
                                           completionHandler:^(NSArray<GKSavedGame *> *savedGames, NSError *error) {
        if (error == nil) {
            std::lock_guard<std::mutex> lock(_stateMutex);
            [self.conflictGroups removeObjectForKey:@(conflictId)];
        }

        std::vector<gm_structs::GameCenterSavedGame> slots;
        for (GKSavedGame *savedGame in savedGames ?: @[]) slots.push_back([self savedGameStructFor:savedGame]);

        gm_structs::GameCenterSavedGamesResolveResult result{};
        GCFillError(result, error);
        result.conflict_id = static_cast<std::int32_t>(conflictId);
        result.slots = std::move(slots);
        callback.call(result);
    }];
}

- (void)player:(GKPlayer *)player hasConflictingSavedGames:(NSArray<GKSavedGame *> *)savedGames
{
    // GameKit can deliver conflicts spanning several filenames in one callback, and each filename
    // must be resolved separately with its own data. Segment by name so every conflict_id maps to
    // exactly one filename's conflicting saves.
    NSMutableDictionary<NSString *, NSMutableArray<GKSavedGame *> *> *byName = [NSMutableDictionary dictionary];
    for (GKSavedGame *savedGame in savedGames ?: @[]) {
        NSString *key = savedGame.name ?: @"";
        NSMutableArray<GKSavedGame *> *group = byName[key];
        if (group == nil) { group = [NSMutableArray array]; byName[key] = group; }
        [group addObject:savedGame];
    }

    // Assign ids and snapshot the callback under the lock; fire events outside it.
    std::vector<std::pair<std::int32_t, NSArray<GKSavedGame *> *>> assigned;
    gm::wire::GMFunction callback;
    {
        std::lock_guard<std::mutex> lock(_stateMutex);
        for (NSString *key in byName) {
            NSInteger conflictId = _nextConflictId++;
            self.conflictGroups[@(conflictId)] = byName[key];
            assigned.emplace_back(static_cast<std::int32_t>(conflictId), byName[key]);
        }
        callback = self.savedGamesEventCallback;
    }

    if (!callback) return;

    for (auto &entry : assigned) {
        std::vector<gm_structs::GameCenterSavedGame> slots;
        for (GKSavedGame *savedGame in entry.second ?: @[]) slots.push_back([self savedGameStructFor:savedGame]);

        gm_structs::GameCenterSavedGamesEvent event{};
        event.type = "conflict";
        event.conflict_id = entry.first;
        event.player = [self playerStructFor:player];
        event.slots = std::move(slots);
        callback.call(event);
    }
}

- (void)player:(GKPlayer *)player didModifySavedGame:(GKSavedGame *)savedGame
{
    gm::wire::GMFunction callback;
    {
        std::lock_guard<std::mutex> lock(_stateMutex);
        callback = self.savedGamesEventCallback;
    }
    if (!callback) return;

    gm_structs::GameCenterSavedGamesEvent event{};
    event.type = "modified";
    event.player = [self playerStructFor:player];
    event.slot = [self savedGameStructFor:savedGame];
    callback.call(event);
}

#pragma mark - Leaderboards

- (void)gamecenter_leaderboard_submit:(std::string_view)leaderboard_id score:(std::int32_t)score context:(std::int32_t)context callback:(gm::wire::GMFunction)callback
{
    NSString *identifier = NSStringFromStringView(leaderboard_id);

    void (^completion)(NSError *) = ^(NSError *error) {
        gm_structs::GameCenterLeaderboardSubmitResult result{};
        GCFillError(result, error);
        result.leaderboard_id = StringFromNSString(identifier);
        result.score = score;
        result.context = context;
        callback.call(result);
    };

    // GameKit score/context are integers; fractional values are truncated.
    [GKLeaderboard submitScore:(NSInteger)score
                       context:(NSUInteger)context
                        player:[GKLocalPlayer localPlayer]
                leaderboardIDs:@[identifier]
             completionHandler:completion];
}

- (void)gamecenter_leaderboard_load:(std::string_view)leaderboard_id
                         time_scope:(gm_enums::GameCenterLeaderboardTimeScope)time_scope
                        range_start:(double)range_start
                        range_count:(double)range_count
                       player_scope:(gm_enums::GameCenterLeaderboardPlayerScope)player_scope
                           callback:(gm::wire::GMFunction)callback
{
    NSString *identifier = NSStringFromStringView(leaderboard_id);
    GKLeaderboardTimeScope ts = static_cast<GKLeaderboardTimeScope>(time_scope);
    GKLeaderboardPlayerScope ps = static_cast<GKLeaderboardPlayerScope>(player_scope);
    // GameKit leaderboard ranges are 1-based (rank 1..N); a start of 0 is invalid and yields
    // empty/garbage results, so clamp it up to 1.
    if (range_start < 1.0) range_start = 1.0;
    // GameKit caps a leaderboard load at 100 entries (the span between min and max rank must not
    // exceed 100); clamp range_count into 1..100 to stay within the documented limit.
    if (range_count < 1.0) range_count = 1.0;
    if (range_count > 100.0) range_count = 100.0;
    NSRange range = NSMakeRange((NSUInteger)range_start, (NSUInteger)range_count);

    [GKLeaderboard loadLeaderboardsWithIDs:@[identifier] completionHandler:^(NSArray<GKLeaderboard *> *leaderboards, NSError *loadError) {
        GKLeaderboard *leaderboard = leaderboards.firstObject;
        if (loadError != nil || leaderboard == nil) {
            gm_structs::GameCenterLeaderboardLoadResult result{};
            GCFillError(result, loadError);
            result.success = false;
            result.leaderboard_id = StringFromNSString(identifier);
            result.local_entry = [self leaderboardEntryStructFor:nil];
            callback.call(result);
            return;
        }

        [leaderboard loadEntriesForPlayerScope:ps timeScope:ts range:range completionHandler:^(GKLeaderboardEntry *localEntry, NSArray<GKLeaderboardEntry *> *entries, NSInteger totalPlayerCount, NSError *error) {
            std::vector<gm_structs::GameCenterLeaderboardEntry> entryArray;
            for (GKLeaderboardEntry *entry in entries ?: @[]) entryArray.push_back([self leaderboardEntryStructFor:entry]);

            gm_structs::GameCenterLeaderboardLoadResult result{};
            GCFillError(result, error);
            result.leaderboard_id = StringFromNSString(identifier);
            result.time_scope = static_cast<std::int32_t>(time_scope);
            result.range_start = range_start;
            result.range_count = range_count;
            result.player_scope = static_cast<std::int32_t>(player_scope);
            result.leaderboard_title = StringFromNSString(leaderboard.title);
            result.leaderboard_group = StringFromNSString(leaderboard.groupIdentifier);
            result.leaderboard_type = static_cast<std::int32_t>(leaderboard.type);
            result.leaderboard_start_date = DateToGMDate(leaderboard.startDate);
            result.leaderboard_next_start_date = DateToGMDate(leaderboard.nextStartDate);
            result.leaderboard_duration = leaderboard.duration;
            result.total_players_count = static_cast<double>(totalPlayerCount);
            result.local_entry = [self leaderboardEntryStructFor:localEntry];
            result.entries = std::move(entryArray);
            callback.call(result);
        }];
    }];
}

#pragma mark - Achievements

- (void)gamecenter_achievement_report:(std::string_view)identifier
                     percent_complete:(double)percent_complete
               show_completion_banner:(bool)show_completion_banner
                             callback:(gm::wire::GMFunction)callback
{
    NSString *achievementId = NSStringFromStringView(identifier);
    GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier:achievementId];
    // GKAchievement.percentComplete must be a whole integer in [0, 100]; clamp + round the GML
    // double (GameKit does not document clamping of out-of-range or fractional values).
    double pct = percent_complete < 0.0 ? 0.0 : (percent_complete > 100.0 ? 100.0 : percent_complete);
    pct = (double)(long)(pct + 0.5);
    achievement.percentComplete = pct;
    achievement.showsCompletionBanner = show_completion_banner;

    [GKAchievement reportAchievements:@[achievement] withCompletionHandler:^(NSError *error) {
        gm_structs::GameCenterAchievementReportResult result{};
        GCFillError(result, error);
        result.identifier = StringFromNSString(achievementId);
        result.percent_complete = pct;
        callback.call(result);
    }];
}

- (void)gamecenter_achievement_reset_all:(gm::wire::GMFunction)callback
{
    [GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error) {
        gm_structs::GameCenterAchievementResetResult result{};
        GCFillError(result, error);
        callback.call(result);
    }];
}

- (void)gamecenter_achievement_load:(gm::wire::GMFunction)callback
{
    [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray<GKAchievement *> *achievements, NSError *error) {
        std::vector<gm_structs::GameCenterAchievement> values;
        for (GKAchievement *achievement in achievements ?: @[]) values.push_back([self achievementStructFor:achievement]);

        gm_structs::GameCenterAchievementsResult result{};
        GCFillError(result, error);
        result.achievements = std::move(values);
        callback.call(result);
    }];
}

#pragma mark - Access point

- (bool)gamecenter_access_point_set_active:(bool)active
{
    if (@available(iOS 14.0, macOS 11.0, *)) { [GKAccessPoint shared].active = active; return true; }
    return false;
}

- (bool)gamecenter_access_point_get_active
{
    if (@available(iOS 14.0, macOS 11.0, *)) return [GKAccessPoint shared].active == YES;
    return false;
}

- (bool)gamecenter_access_point_set_location:(gm_enums::GameCenterAccessPointLocation)location
{
    if (@available(iOS 14.0, macOS 11.0, *)) {
        [GKAccessPoint shared].location = static_cast<GKAccessPointLocation>(location);
        return true;
    }
    return false;
}

- (double)gamecenter_access_point_get_location
{
    if (@available(iOS 14.0, macOS 11.0, *)) return (double)[GKAccessPoint shared].location;
    return -1;
}

- (bool)gamecenter_access_point_is_presenting_game_center
{
    if (@available(iOS 14.0, macOS 11.0, *)) return [GKAccessPoint shared].isPresentingGameCenter == YES;
    return false;
}

- (bool)gamecenter_access_point_is_visible
{
    if (@available(iOS 14.0, macOS 11.0, *)) return [GKAccessPoint shared].visible == YES;
    return false;
}

- (bool)gamecenter_access_point_set_show_highlights:(bool)show
{
    if (@available(iOS 14.0, macOS 11.0, *)) { [GKAccessPoint shared].showHighlights = show; return true; }
    return false;
}

- (bool)gamecenter_access_point_get_show_highlights
{
    if (@available(iOS 14.0, macOS 11.0, *)) return [GKAccessPoint shared].showHighlights == YES;
    return false;
}

- (double)gamecenter_access_point_get_coordinate:(gm_enums::GameCenterAccessPointCoordinate)coordinate
{
    if (@available(iOS 14.0, macOS 11.0, *)) {
        CGRect frame = [GKAccessPoint shared].frameInScreenCoordinates;
        switch (coordinate) {
            case gm_enums::GameCenterAccessPointCoordinate::X: return frame.origin.x;
            case gm_enums::GameCenterAccessPointCoordinate::Y: return frame.origin.y;
            case gm_enums::GameCenterAccessPointCoordinate::Width: return frame.size.width;
            case gm_enums::GameCenterAccessPointCoordinate::Height: return frame.size.height;
        }
    }
    return 0;
}

- (bool)gamecenter_access_point_present_with_state:(gm_enums::GameCenterViewState)state
                                          callback:(gm::wire::GMFunction)callback
{
    // Check availability for iOS 17.2+ / macOS 14.2+ states (Challenges, Dashboard, LocalPlayerFriendsList).
    auto stateInt = static_cast<int>(state);
    if (!(@available(iOS 17.2, macOS 14.2, *))) {
        if (stateInt == 2 || stateInt == 4 || stateInt == 5) {
            callback.call();
            return false;
        }
    }

    if (@available(iOS 14.0, macOS 11.0, *)) {
        [[GKAccessPoint shared] triggerAccessPointWithState:static_cast<GKGameCenterViewControllerState>(state) handler:^{
            callback.call();
        }];
        return true;
    }

    // Unsupported OS: signal failure through the callback so a caller awaiting it doesn't hang.
    callback.call();
    return false;
}

- (bool)gamecenter_access_point_present:(gm::wire::GMFunction)callback
{
    if (@available(iOS 14.0, macOS 11.0, *)) {
        [[GKAccessPoint shared] triggerAccessPointWithHandler:^{
            callback.call();
        }];
        return true;
    }
    callback.call();
    return false;
}

@end
