// macOS implementation of the GameCenter native (C++) free-function API.
//
// The desktop targets run in extgen "native" mode: code_gen/native exposes the
// GMEXPORT C entry points which forward to the free gamecenter_* functions
// declared in code_gen/native/GMGameCenterInternal_native.h. This file provides
// those functions for macOS using GameKit.
//
// The iOS target (src/ios/GMGameCenter_ios.mm) implements the same surface as an
// Objective-C class because iOS runs in "objc" mode. The GameKit logic mirrors
// that file. The main macOS difference is presentation: dialogs are shown with
// GKDialogController over the application's key window (AppKit) rather than via
// the iOS-only g_controller / UIViewController presentation path.

#import "GMGameCenter_native.h"

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <GameKit/GameKit.h>

#include <cstdint>
#include <mutex>
#include <stdexcept>
#include <string>
#include <string_view>
#include <utility>
#include <vector>

using namespace gm_structs;
using namespace gm_enums;

#pragma mark - Conversion helpers

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

#pragma mark - Internal state holder / GameKit delegate

// GKGameCenterControllerDelegate is deprecated as of iOS/macOS 26.0 (whole protocol, alongside
// GKGameCenterViewController). Kept because gamecenter_present_view_achievement/_leaderboard (per-ID
// deep-links) have no GKAccessPoint equivalent as of iOS 26; revisit if Apple ships one.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
@interface GMGameCenterMac : NSObject <GKLocalPlayerListener, GKGameCenterControllerDelegate>
#pragma clang diagnostic pop

+ (instancetype)shared;

@property(nonatomic, strong) NSMutableDictionary<NSNumber *, NSArray<GKSavedGame *> *> *conflictGroups;
@property(nonatomic, strong) NSMutableDictionary<NSNumber *, NSData *> *heldSavedGameData;

// View presentation
- (void)gamecenter_view_callback_subscribe:(gm::wire::GMFunction)callback;
- (bool)gamecenter_present_view_achievement:(std::string_view)achievement_id;
- (bool)gamecenter_present_view_leaderboard:(std::string_view)leaderboard_id
                                 time_scope:(gm_enums::GameCenterLeaderboardTimeScope)time_scope
                               player_scope:(gm_enums::GameCenterLeaderboardPlayerScope)player_scope;

// Local player
- (void)gamecenter_local_player_authenticate:(gm::wire::GMFunction)callback;
- (bool)gamecenter_local_player_is_authenticated;
- (bool)gamecenter_local_player_is_underage;
- (bool)gamecenter_local_player_is_multiplayer_gaming_restricted;
- (bool)gamecenter_local_player_is_personalized_communication_restricted;
- (gm_structs::GameCenterPlayer)gamecenter_local_player_get_info;

// Saved games
- (void)gamecenter_saved_games_callback_subscribe:(gm::wire::GMFunction)callback;
- (void)gamecenter_saved_games_fetch:(gm::wire::GMFunction)callback;
- (void)gamecenter_saved_games_save:(std::string_view)name data:(gm::wire::GMBuffer)buffer callback:(gm::wire::GMFunction)callback;
- (void)gamecenter_saved_games_delete:(std::string_view)name callback:(gm::wire::GMFunction)callback;
- (void)gamecenter_saved_games_data_request:(std::string_view)name callback:(gm::wire::GMFunction)callback;
- (bool)gamecenter_saved_games_data_fetch:(double)handle_id data:(gm::wire::GMBuffer)buffer;
- (bool)gamecenter_saved_games_data_release:(double)handle_id;
- (void)gamecenter_saved_games_resolve_conflict:(double)conflict_id data:(gm::wire::GMBuffer)buffer callback:(gm::wire::GMFunction)callback;

// Leaderboards
- (void)gamecenter_leaderboard_submit:(std::string_view)leaderboard_id score:(std::int32_t)score context:(std::int32_t)context callback:(gm::wire::GMFunction)callback;
- (void)gamecenter_leaderboard_load:(std::string_view)leaderboard_id
                         time_scope:(gm_enums::GameCenterLeaderboardTimeScope)time_scope
                        range_start:(double)range_start
                        range_count:(double)range_count
                       player_scope:(gm_enums::GameCenterLeaderboardPlayerScope)player_scope
                           callback:(gm::wire::GMFunction)callback;

// Achievements
- (void)gamecenter_achievement_report:(std::string_view)identifier percent_complete:(double)percent_complete show_completion_banner:(bool)show_completion_banner callback:(gm::wire::GMFunction)callback;
- (void)gamecenter_achievement_reset_all:(gm::wire::GMFunction)callback;
- (void)gamecenter_achievement_load:(gm::wire::GMFunction)callback;

// Access point
- (bool)gamecenter_access_point_set_active:(bool)active;
- (bool)gamecenter_access_point_get_active;
- (bool)gamecenter_access_point_set_location:(gm_enums::GameCenterAccessPointLocation)location;
- (double)gamecenter_access_point_get_location;
- (bool)gamecenter_access_point_is_presenting_game_center;
- (bool)gamecenter_access_point_is_visible;
- (bool)gamecenter_access_point_set_show_highlights:(bool)show;
- (bool)gamecenter_access_point_get_show_highlights;
- (double)gamecenter_access_point_get_coordinate:(gm_enums::GameCenterAccessPointCoordinate)coordinate;
- (bool)gamecenter_access_point_present_with_state:(gm_enums::GameCenterViewState)state callback:(gm::wire::GMFunction)callback;
- (bool)gamecenter_access_point_present:(gm::wire::GMFunction)callback;

@end

@implementation GMGameCenterMac {
    gm::wire::GMFunction _viewCallback;
    gm::wire::GMFunction _savedGamesEventCallback;
    gm::wire::GMFunction _authenticateCallback;
    // Guards _viewCallback / _savedGamesEventCallback / _authenticateCallback / conflictGroups /
    // heldSavedGameData against concurrent access from GameKit listener/delegate callbacks (not
    // guaranteed to be on the main thread) and the game-thread entry points. Callbacks are copied
    // under the lock and fired outside it.
    std::mutex _stateMutex;
    NSInteger _nextConflictId;
    NSInteger _nextDataHandleId;
    BOOL _authenticateHandlerSet;
}

+ (instancetype)shared
{
    static GMGameCenterMac *instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{ instance = [[GMGameCenterMac alloc] init]; });
    return instance;
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
    }
    return self;
}

- (void)dealloc
{
    [[GKLocalPlayer localPlayer] unregisterListener:self];
    self.conflictGroups = nil;
    self.heldSavedGameData = nil;
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

#pragma mark - Presentation (macOS)

// GameKit dialogs on macOS are shown through the shared GKDialogController, which
// needs a host window to anchor to. Use the application's key/main window.
- (NSWindow *)parentWindow
{
    NSApplication *app = [NSApplication sharedApplication];
    NSWindow *window = app.keyWindow;
    if (window == nil) window = app.mainWindow;
    if (window == nil) window = app.windows.firstObject;
    return window;
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

    GKDialogController *dialog = [GKDialogController sharedDialogController];
    dialog.parentWindow = [self parentWindow];
    return [dialog presentViewController:(NSViewController<GKViewController> *)controller] == YES;
}

#pragma mark - View presentation

- (void)gamecenter_view_callback_subscribe:(gm::wire::GMFunction)callback
{
    std::lock_guard<std::mutex> lock(_stateMutex);
    _viewCallback = callback;
}

- (bool)gamecenter_present_view_achievement:(std::string_view)achievement_id
{
    GKGameCenterViewController *controller =
        [[GKGameCenterViewController alloc] initWithAchievementID:NSStringFromStringView(achievement_id)];
    return [self presentController:controller];
}

- (bool)gamecenter_present_view_leaderboard:(std::string_view)leaderboard_id
                                 time_scope:(gm_enums::GameCenterLeaderboardTimeScope)time_scope
                               player_scope:(gm_enums::GameCenterLeaderboardPlayerScope)player_scope
{
    GKLeaderboardTimeScope ts = static_cast<GKLeaderboardTimeScope>(time_scope);
    GKLeaderboardPlayerScope ps = static_cast<GKLeaderboardPlayerScope>(player_scope);

    GKGameCenterViewController *controller =
        [[GKGameCenterViewController alloc] initWithLeaderboardID:NSStringFromStringView(leaderboard_id)
                                                     playerScope:ps
                                                       timeScope:ts];
    return [self presentController:controller];
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)controller
{
    [[GKDialogController sharedDialogController] dismiss:self];

    gm::wire::GMFunction viewCallback;
    {
        std::lock_guard<std::mutex> lock(_stateMutex);
        viewCallback = _viewCallback;
    }
    if (viewCallback) {
        viewCallback.call();
    }
}
#pragma clang diagnostic pop

#pragma mark - Local player

- (void)setupAuthenticationHandler
{
    if (_authenticateHandlerSet) return;
    _authenticateHandlerSet = YES;

    [GKLocalPlayer localPlayer].authenticateHandler = ^(NSViewController *viewController, NSError *error) {
        GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
        std::string state = "unknown";

        if (viewController != nil) {
            GKDialogController *dialog = [GKDialogController sharedDialogController];
            dialog.parentWindow = [self parentWindow];
            [dialog presentViewController:(NSViewController<GKViewController> *)viewController];
            state = "presenting_view";
        } else if (localPlayer.isAuthenticated) {
            state = "authenticated";
        }

        gm::wire::GMFunction callback;
        {
            std::lock_guard<std::mutex> lock(_stateMutex);
            callback = _authenticateCallback;
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

- (void)gamecenter_local_player_authenticate:(gm::wire::GMFunction)callback
{
    {
        std::lock_guard<std::mutex> lock(_stateMutex);
        _authenticateCallback = callback;
    }
    // Install the persistent GameKit handler only after a callback is registered, so the initial
    // authentication result can never fire before GML is listening. GameKit retains this handler and
    // re-invokes it on every auth-state change (sign in/out, foregrounding); we keep the single
    // handler and just swap the stored callback, so it is installed exactly once.
    [self setupAuthenticationHandler];
}

- (bool)gamecenter_local_player_is_authenticated { return [GKLocalPlayer localPlayer].isAuthenticated == YES; }
- (bool)gamecenter_local_player_is_underage { return [GKLocalPlayer localPlayer].isUnderage == YES; }

- (bool)gamecenter_local_player_is_multiplayer_gaming_restricted
{
    return [GKLocalPlayer localPlayer].isMultiplayerGamingRestricted == YES;
}

- (bool)gamecenter_local_player_is_personalized_communication_restricted
{
    return [GKLocalPlayer localPlayer].isPersonalizedCommunicationRestricted == YES;
}

- (gm_structs::GameCenterPlayer)gamecenter_local_player_get_info
{
    return [self playerStructFor:[GKLocalPlayer localPlayer]];
}

#pragma mark - Saved games

- (void)gamecenter_saved_games_callback_subscribe:(gm::wire::GMFunction)callback
{
    std::lock_guard<std::mutex> lock(_stateMutex);
    _savedGamesEventCallback = callback;
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
            // Resolved: drop the stored group so it can't be resolved twice or leak.
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
        callback = _savedGamesEventCallback;
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
        callback = _savedGamesEventCallback;
    }
    if (!callback) return;

    gm_structs::GameCenterSavedGamesEvent event{};
    event.type = "modified";
    event.player = [self playerStructFor:player];
    event.slot = [self savedGameStructFor:savedGame];
    callback.call(event);
}

#pragma mark - Leaderboards

- (void)gamecenter_leaderboard_submit:(std::string_view)leaderboard_id
                                score:(std::int32_t)score
                              context:(std::int32_t)context
                             callback:(gm::wire::GMFunction)callback
{
    NSString *identifier = NSStringFromStringView(leaderboard_id);

    // GameKit score/context are integers; fractional values are truncated.
    [GKLeaderboard submitScore:(NSInteger)score
                       context:(NSUInteger)context
                        player:[GKLocalPlayer localPlayer]
                leaderboardIDs:@[identifier]
             completionHandler:^(NSError *error) {
        gm_structs::GameCenterLeaderboardSubmitResult result{};
        GCFillError(result, error);
        result.leaderboard_id = StringFromNSString(identifier);
        result.score = score;
        result.context = context;
        callback.call(result);
    }];
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
    [GKAccessPoint shared].active = active;
    return true;
}

- (bool)gamecenter_access_point_get_active { return [GKAccessPoint shared].active == YES; }

- (bool)gamecenter_access_point_set_location:(gm_enums::GameCenterAccessPointLocation)location
{
    [GKAccessPoint shared].location = static_cast<GKAccessPointLocation>(location);
    return true;
}

- (double)gamecenter_access_point_get_location { return (double)[GKAccessPoint shared].location; }

- (bool)gamecenter_access_point_is_presenting_game_center { return [GKAccessPoint shared].isPresentingGameCenter == YES; }

- (bool)gamecenter_access_point_is_visible { return [GKAccessPoint shared].visible == YES; }

- (bool)gamecenter_access_point_set_show_highlights:(bool)show
{
    [GKAccessPoint shared].showHighlights = show;
    return true;
}

- (bool)gamecenter_access_point_get_show_highlights { return [GKAccessPoint shared].showHighlights == YES; }

- (double)gamecenter_access_point_get_coordinate:(gm_enums::GameCenterAccessPointCoordinate)coordinate
{
    CGRect frame = [GKAccessPoint shared].frameInScreenCoordinates;
    switch (coordinate) {
        case gm_enums::GameCenterAccessPointCoordinate::X: return frame.origin.x;
        case gm_enums::GameCenterAccessPointCoordinate::Y: return frame.origin.y;
        case gm_enums::GameCenterAccessPointCoordinate::Width: return frame.size.width;
        case gm_enums::GameCenterAccessPointCoordinate::Height: return frame.size.height;
    }
    return 0;
}

- (bool)gamecenter_access_point_present_with_state:(gm_enums::GameCenterViewState)state
                                          callback:(gm::wire::GMFunction)callback
{
    // Challenges (2), Dashboard (4) and LocalPlayerFriendsList (5) require iOS 17.2 / macOS 14.2;
    // on older systems reject rather than present an empty/unexpected dashboard.
    auto stateInt = static_cast<int>(state);
    if (!(@available(iOS 17.2, macOS 14.2, *))) {
        if (stateInt == 2 || stateInt == 4 || stateInt == 5) {
            callback.call();
            return false;
        }
    }

    [[GKAccessPoint shared] triggerAccessPointWithState:static_cast<GKGameCenterViewControllerState>(state) handler:^{
        callback.call();
    }];
    return true;
}

- (bool)gamecenter_access_point_present:(gm::wire::GMFunction)callback
{
    [[GKAccessPoint shared] triggerAccessPointWithHandler:^{
        callback.call();
    }];
    return true;
}

@end

#pragma mark - C++ free-function API (called by the code_gen/native shim)

void gamecenter_view_callback_subscribe(const gm::wire::GMFunction& callback)
{
    [[GMGameCenterMac shared] gamecenter_view_callback_subscribe:callback];
}

bool gamecenter_present_view_achievement(std::string_view achievement_id)
{
    return [[GMGameCenterMac shared] gamecenter_present_view_achievement:achievement_id];
}

bool gamecenter_present_view_leaderboard(std::string_view leaderboard_id,
                                         gm_enums::GameCenterLeaderboardTimeScope time_scope,
                                         gm_enums::GameCenterLeaderboardPlayerScope player_scope)
{
    return [[GMGameCenterMac shared] gamecenter_present_view_leaderboard:leaderboard_id
                                                            time_scope:time_scope
                                                          player_scope:player_scope];
}

void gamecenter_local_player_authenticate(const gm::wire::GMFunction& callback)
{
    [[GMGameCenterMac shared] gamecenter_local_player_authenticate:callback];
}

bool gamecenter_local_player_is_authenticated()
{
    return [[GMGameCenterMac shared] gamecenter_local_player_is_authenticated];
}

bool gamecenter_local_player_is_underage()
{
    return [[GMGameCenterMac shared] gamecenter_local_player_is_underage];
}

bool gamecenter_local_player_is_multiplayer_gaming_restricted()
{
    return [[GMGameCenterMac shared] gamecenter_local_player_is_multiplayer_gaming_restricted];
}

bool gamecenter_local_player_is_personalized_communication_restricted()
{
    return [[GMGameCenterMac shared] gamecenter_local_player_is_personalized_communication_restricted];
}

gm_structs::GameCenterPlayer gamecenter_local_player_get_info()
{
    return [[GMGameCenterMac shared] gamecenter_local_player_get_info];
}

void gamecenter_saved_games_callback_subscribe(const gm::wire::GMFunction& callback)
{
    [[GMGameCenterMac shared] gamecenter_saved_games_callback_subscribe:callback];
}

void gamecenter_saved_games_fetch(const gm::wire::GMFunction& callback)
{
    [[GMGameCenterMac shared] gamecenter_saved_games_fetch:callback];
}

void gamecenter_saved_games_save(std::string_view name, gm::wire::GMBuffer data, const gm::wire::GMFunction& callback)
{
    [[GMGameCenterMac shared] gamecenter_saved_games_save:name data:data callback:callback];
}

void gamecenter_saved_games_delete(std::string_view name, const gm::wire::GMFunction& callback)
{
    [[GMGameCenterMac shared] gamecenter_saved_games_delete:name callback:callback];
}

void gamecenter_saved_games_data_request(std::string_view name, const gm::wire::GMFunction& callback)
{
    [[GMGameCenterMac shared] gamecenter_saved_games_data_request:name callback:callback];
}

bool gamecenter_saved_games_data_fetch(double handle_id, gm::wire::GMBuffer data)
{
    return [[GMGameCenterMac shared] gamecenter_saved_games_data_fetch:handle_id data:data];
}

bool gamecenter_saved_games_data_release(double handle_id)
{
    return [[GMGameCenterMac shared] gamecenter_saved_games_data_release:handle_id];
}

void gamecenter_saved_games_resolve_conflict(double conflict_id, gm::wire::GMBuffer data, const gm::wire::GMFunction& callback)
{
    [[GMGameCenterMac shared] gamecenter_saved_games_resolve_conflict:conflict_id data:data callback:callback];
}

void gamecenter_leaderboard_submit(std::string_view leaderboard_id, std::int32_t score, std::int32_t context, const gm::wire::GMFunction& callback)
{
    [[GMGameCenterMac shared] gamecenter_leaderboard_submit:leaderboard_id score:score context:context callback:callback];
}

void gamecenter_leaderboard_load(std::string_view leaderboard_id,
                                 gm_enums::GameCenterLeaderboardTimeScope time_scope,
                                 double range_start,
                                 double range_count,
                                 gm_enums::GameCenterLeaderboardPlayerScope player_scope,
                                 const gm::wire::GMFunction& callback)
{
    [[GMGameCenterMac shared] gamecenter_leaderboard_load:leaderboard_id
                                              time_scope:time_scope
                                             range_start:range_start
                                             range_count:range_count
                                            player_scope:player_scope
                                                callback:callback];
}

void gamecenter_achievement_report(std::string_view identifier, double percent_complete, bool show_completion_banner, const gm::wire::GMFunction& callback)
{
    [[GMGameCenterMac shared] gamecenter_achievement_report:identifier
                                          percent_complete:percent_complete
                                    show_completion_banner:show_completion_banner
                                                  callback:callback];
}

void gamecenter_achievement_reset_all(const gm::wire::GMFunction& callback)
{
    [[GMGameCenterMac shared] gamecenter_achievement_reset_all:callback];
}

void gamecenter_achievement_load(const gm::wire::GMFunction& callback)
{
    [[GMGameCenterMac shared] gamecenter_achievement_load:callback];
}

bool gamecenter_access_point_set_active(bool active)
{
    return [[GMGameCenterMac shared] gamecenter_access_point_set_active:active];
}

bool gamecenter_access_point_get_active()
{
    return [[GMGameCenterMac shared] gamecenter_access_point_get_active];
}

bool gamecenter_access_point_set_location(gm_enums::GameCenterAccessPointLocation location)
{
    return [[GMGameCenterMac shared] gamecenter_access_point_set_location:location];
}

double gamecenter_access_point_get_location()
{
    return [[GMGameCenterMac shared] gamecenter_access_point_get_location];
}

bool gamecenter_access_point_is_presenting_game_center()
{
    return [[GMGameCenterMac shared] gamecenter_access_point_is_presenting_game_center];
}

bool gamecenter_access_point_is_visible()
{
    return [[GMGameCenterMac shared] gamecenter_access_point_is_visible];
}

bool gamecenter_access_point_set_show_highlights(bool show)
{
    return [[GMGameCenterMac shared] gamecenter_access_point_set_show_highlights:show];
}

bool gamecenter_access_point_get_show_highlights()
{
    return [[GMGameCenterMac shared] gamecenter_access_point_get_show_highlights];
}

double gamecenter_access_point_get_coordinate(gm_enums::GameCenterAccessPointCoordinate coordinate)
{
    return [[GMGameCenterMac shared] gamecenter_access_point_get_coordinate:coordinate];
}

bool gamecenter_access_point_present_with_state(gm_enums::GameCenterViewState state, const gm::wire::GMFunction& callback)
{
    return [[GMGameCenterMac shared] gamecenter_access_point_present_with_state:state callback:callback];
}

bool gamecenter_access_point_present(const gm::wire::GMFunction& callback)
{
    return [[GMGameCenterMac shared] gamecenter_access_point_present:callback];
}
