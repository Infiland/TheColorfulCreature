// ##### extgen :: Auto-generated file do not edit!! #####

#import <objc/runtime.h>
#import "core/GMExtUtils.h"
#import "GMGameCenterInternal_ios.h"


extern "C" const char* extOptGetString(char* _ext, char* _opt);

// Adapter: matches const signature expected by the C++ API
static const char* ExtOptGetString(const char* ext, const char* opt)
{
    return extOptGetString(const_cast<char*>(ext), const_cast<char*>(opt));
}

static BOOL GMIsSubclassOf(Class cls, Class base)
{
    for (Class c = cls; c != Nil; c = class_getSuperclass(c)) {
        if (c == base) return YES;
    }
    return NO;
}

static void GMInjectSelectorsIntoSubclass(Class subclass, Class base)
{
    // Build set of methods already defined on subclass
    unsigned subCount = 0;
    Method *subList = class_copyMethodList(subclass, &subCount);

    CFMutableSetRef owned = CFSetCreateMutable(kCFAllocatorDefault, 0, NULL);
    for (unsigned i = 0; i < subCount; ++i) {
        CFSetAddValue(owned, method_getName(subList[i]));
    }

    // Walk base class methods
    unsigned baseCount = 0;
    Method *baseList = class_copyMethodList(base, &baseCount);

    for (unsigned i = 0; i < baseCount; ++i) {
        SEL sel = method_getName(baseList[i]);
        const char *name = sel_getName(sel);

        // Only inject extension selectors (methods prefixed with __EXT_NATIVE__)
        if (!name || strncmp(name, "__EXT_NATIVE__", 13) != 0) continue;

        // Add only if subclass doesn't already have it
        if (!CFSetContainsValue(owned, sel)) {
            IMP imp = method_getImplementation(baseList[i]);
            const char *types = method_getTypeEncoding(baseList[i]);
            if (class_addMethod(subclass, sel, imp, types)) {
                CFSetAddValue(owned, sel);
            }
        }
    }

    if (subList) free(subList);
    if (baseList) free(baseList);
    if (owned) CFRelease(owned);
}

@interface GMGameCenterInternal ()
{
    gm::runtime::DispatchQueue __dispatch_queue;
    std::queue<gm::wire::GMBuffer> __buffer_queue;
    id<GMGameCenterInterface> __impl;
}@end


@implementation GMGameCenterInternal

+ (void)load
{
    // Find all loaded classes
    int num = objc_getClassList(NULL, 0);
    if (num <= 0) return;

    Class *classes = (Class *)malloc(sizeof(Class) * (unsigned)num);
    num = objc_getClassList(classes, num);

    Class base = [GMGameCenterInternal class];

    for (int i = 0; i < num; ++i) {
        Class cls = classes[i];
        if (cls == base) continue;

        // We only care about direct or indirect subclasses
        if (GMIsSubclassOf(cls, base)) {
            GMInjectSelectorsIntoSubclass(cls, base);
        }
    }

    free(classes);

    gm::details::GMRTRunnerInterface ri{};
    ri.ExtOptGetString = &ExtOptGetString;
    GMExtensionInitialise(&ri, sizeof(ri));
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        __impl = (id<GMGameCenterInterface>)self;
    }
    return self;
}
- (double)__EXT_NATIVE__gamecenter_view_callback_subscribe:(char*)__arg_buffer arg1:(double)__arg_buffer_length
{
    gm::byteio::BufferReader __br{__arg_buffer, static_cast<size_t>(__arg_buffer_length)};

    // field: callback, type: Function
    gm::wire::GMFunction callback = gm::wire::codec::readFunction(__br, &__dispatch_queue);

    [__impl gamecenter_view_callback_subscribe:callback];

    return 0;
}

- (double)__EXT_NATIVE__gamecenter_present_view_achievement:(char*)achievement_id
{
    bool __result = [__impl gamecenter_present_view_achievement:achievement_id];

    return static_cast<double>(__result);
}

- (double)__EXT_NATIVE__gamecenter_present_view_leaderboard:(char*)__arg_buffer arg1:(double)__arg_buffer_length
{
    gm::byteio::BufferReader __br{__arg_buffer, static_cast<size_t>(__arg_buffer_length)};

    // field: leaderboard_id, type: String
    std::string_view leaderboard_id = gm::wire::codec::readValue<std::string_view>(__br);

    // field: time_scope, type: enum GameCenterLeaderboardTimeScope
    gm_enums::GameCenterLeaderboardTimeScope time_scope = gm::wire::codec::readValue<gm_enums::GameCenterLeaderboardTimeScope>(__br);

    // field: player_scope, type: enum GameCenterLeaderboardPlayerScope
    gm_enums::GameCenterLeaderboardPlayerScope player_scope = gm::wire::codec::readValue<gm_enums::GameCenterLeaderboardPlayerScope>(__br);

    bool __result = [__impl gamecenter_present_view_leaderboard:leaderboard_id time_scope:time_scope player_scope:player_scope];

    return static_cast<double>(__result);
}

- (double)__EXT_NATIVE__gamecenter_local_player_authenticate:(char*)__arg_buffer arg1:(double)__arg_buffer_length
{
    gm::byteio::BufferReader __br{__arg_buffer, static_cast<size_t>(__arg_buffer_length)};

    // field: callback, type: Function
    gm::wire::GMFunction callback = gm::wire::codec::readFunction(__br, &__dispatch_queue);

    [__impl gamecenter_local_player_authenticate:callback];

    return 0;
}

- (double)__EXT_NATIVE__gamecenter_local_player_is_authenticated
{
    bool __result = [__impl gamecenter_local_player_is_authenticated];

    return static_cast<double>(__result);
}

- (double)__EXT_NATIVE__gamecenter_local_player_is_underage
{
    bool __result = [__impl gamecenter_local_player_is_underage];

    return static_cast<double>(__result);
}

- (double)__EXT_NATIVE__gamecenter_local_player_is_multiplayer_gaming_restricted
{
    bool __result = [__impl gamecenter_local_player_is_multiplayer_gaming_restricted];

    return static_cast<double>(__result);
}

- (double)__EXT_NATIVE__gamecenter_local_player_is_personalized_communication_restricted
{
    bool __result = [__impl gamecenter_local_player_is_personalized_communication_restricted];

    return static_cast<double>(__result);
}

- (double)__EXT_NATIVE__gamecenter_local_player_get_info:(char*)__ret_buffer arg1:(double)__ret_buffer_length
{
    gm_structs::GameCenterPlayer __result = [__impl gamecenter_local_player_get_info];

    gm::byteio::BufferWriter __bw{__ret_buffer, static_cast<size_t>(__ret_buffer_length)};

    // return: __result, type: struct GameCenterPlayer
    gm::wire::codec::writeValue(__bw, __result);
    return 0;
}

- (double)__EXT_NATIVE__gamecenter_saved_games_callback_subscribe:(char*)__arg_buffer arg1:(double)__arg_buffer_length
{
    gm::byteio::BufferReader __br{__arg_buffer, static_cast<size_t>(__arg_buffer_length)};

    // field: callback, type: Function
    gm::wire::GMFunction callback = gm::wire::codec::readFunction(__br, &__dispatch_queue);

    [__impl gamecenter_saved_games_callback_subscribe:callback];

    return 0;
}

- (double)__EXT_NATIVE__gamecenter_saved_games_fetch:(char*)__arg_buffer arg1:(double)__arg_buffer_length
{
    gm::byteio::BufferReader __br{__arg_buffer, static_cast<size_t>(__arg_buffer_length)};

    // field: callback, type: Function
    gm::wire::GMFunction callback = gm::wire::codec::readFunction(__br, &__dispatch_queue);

    [__impl gamecenter_saved_games_fetch:callback];

    return 0;
}

- (double)__EXT_NATIVE__gamecenter_saved_games_save:(char*)__arg_buffer arg1:(double)__arg_buffer_length
{
    gm::byteio::BufferReader __br{__arg_buffer, static_cast<size_t>(__arg_buffer_length)};

    // field: name, type: String
    std::string_view name = gm::wire::codec::readValue<std::string_view>(__br);

    // field: data, type: Buffer
    gm::wire::GMBuffer data = __buffer_queue.front();
    __buffer_queue.pop();

    // field: callback, type: Function
    gm::wire::GMFunction callback = gm::wire::codec::readFunction(__br, &__dispatch_queue);

    [__impl gamecenter_saved_games_save:name data:data callback:callback];

    return 0;
}

- (double)__EXT_NATIVE__gamecenter_saved_games_delete:(char*)__arg_buffer arg1:(double)__arg_buffer_length
{
    gm::byteio::BufferReader __br{__arg_buffer, static_cast<size_t>(__arg_buffer_length)};

    // field: name, type: String
    std::string_view name = gm::wire::codec::readValue<std::string_view>(__br);

    // field: callback, type: Function
    gm::wire::GMFunction callback = gm::wire::codec::readFunction(__br, &__dispatch_queue);

    [__impl gamecenter_saved_games_delete:name callback:callback];

    return 0;
}

- (double)__EXT_NATIVE__gamecenter_saved_games_data_request:(char*)__arg_buffer arg1:(double)__arg_buffer_length
{
    gm::byteio::BufferReader __br{__arg_buffer, static_cast<size_t>(__arg_buffer_length)};

    // field: name, type: String
    std::string_view name = gm::wire::codec::readValue<std::string_view>(__br);

    // field: callback, type: Function
    gm::wire::GMFunction callback = gm::wire::codec::readFunction(__br, &__dispatch_queue);

    [__impl gamecenter_saved_games_data_request:name callback:callback];

    return 0;
}

- (double)__EXT_NATIVE__gamecenter_saved_games_data_fetch:(char*)__arg_buffer arg1:(double)__arg_buffer_length
{
    gm::byteio::BufferReader __br{__arg_buffer, static_cast<size_t>(__arg_buffer_length)};

    // field: handle_id, type: Float64
    double handle_id = gm::wire::codec::readValue<double>(__br);

    // field: data, type: Buffer
    gm::wire::GMBuffer data = __buffer_queue.front();
    __buffer_queue.pop();

    bool __result = [__impl gamecenter_saved_games_data_fetch:handle_id data:data];

    return static_cast<double>(__result);
}

- (double)__EXT_NATIVE__gamecenter_saved_games_data_release:(double)handle_id
{
    bool __result = [__impl gamecenter_saved_games_data_release:handle_id];

    return static_cast<double>(__result);
}

- (double)__EXT_NATIVE__gamecenter_saved_games_resolve_conflict:(char*)__arg_buffer arg1:(double)__arg_buffer_length
{
    gm::byteio::BufferReader __br{__arg_buffer, static_cast<size_t>(__arg_buffer_length)};

    // field: conflict_id, type: Float64
    double conflict_id = gm::wire::codec::readValue<double>(__br);

    // field: data, type: Buffer
    gm::wire::GMBuffer data = __buffer_queue.front();
    __buffer_queue.pop();

    // field: callback, type: Function
    gm::wire::GMFunction callback = gm::wire::codec::readFunction(__br, &__dispatch_queue);

    [__impl gamecenter_saved_games_resolve_conflict:conflict_id data:data callback:callback];

    return 0;
}

- (double)__EXT_NATIVE__gamecenter_leaderboard_submit:(char*)__arg_buffer arg1:(double)__arg_buffer_length
{
    gm::byteio::BufferReader __br{__arg_buffer, static_cast<size_t>(__arg_buffer_length)};

    // field: leaderboard_id, type: String
    std::string_view leaderboard_id = gm::wire::codec::readValue<std::string_view>(__br);

    // field: score, type: Int32
    std::int32_t score = gm::wire::codec::readValue<std::int32_t>(__br);

    // field: context, type: Int32
    std::int32_t context = gm::wire::codec::readValue<std::int32_t>(__br);

    // field: callback, type: Function
    gm::wire::GMFunction callback = gm::wire::codec::readFunction(__br, &__dispatch_queue);

    [__impl gamecenter_leaderboard_submit:leaderboard_id score:score context:context callback:callback];

    return 0;
}

- (double)__EXT_NATIVE__gamecenter_leaderboard_load:(char*)__arg_buffer arg1:(double)__arg_buffer_length
{
    gm::byteio::BufferReader __br{__arg_buffer, static_cast<size_t>(__arg_buffer_length)};

    // field: leaderboard_id, type: String
    std::string_view leaderboard_id = gm::wire::codec::readValue<std::string_view>(__br);

    // field: time_scope, type: enum GameCenterLeaderboardTimeScope
    gm_enums::GameCenterLeaderboardTimeScope time_scope = gm::wire::codec::readValue<gm_enums::GameCenterLeaderboardTimeScope>(__br);

    // field: range_start, type: Float64
    double range_start = gm::wire::codec::readValue<double>(__br);

    // field: range_count, type: Float64
    double range_count = gm::wire::codec::readValue<double>(__br);

    // field: player_scope, type: enum GameCenterLeaderboardPlayerScope
    gm_enums::GameCenterLeaderboardPlayerScope player_scope = gm::wire::codec::readValue<gm_enums::GameCenterLeaderboardPlayerScope>(__br);

    // field: callback, type: Function
    gm::wire::GMFunction callback = gm::wire::codec::readFunction(__br, &__dispatch_queue);

    [__impl gamecenter_leaderboard_load:leaderboard_id time_scope:time_scope range_start:range_start range_count:range_count player_scope:player_scope callback:callback];

    return 0;
}

- (double)__EXT_NATIVE__gamecenter_achievement_report:(char*)__arg_buffer arg1:(double)__arg_buffer_length
{
    gm::byteio::BufferReader __br{__arg_buffer, static_cast<size_t>(__arg_buffer_length)};

    // field: identifier, type: String
    std::string_view identifier = gm::wire::codec::readValue<std::string_view>(__br);

    // field: percent_complete, type: Float64
    double percent_complete = gm::wire::codec::readValue<double>(__br);

    // field: show_completion_banner, type: Bool
    bool show_completion_banner = gm::wire::codec::readValue<bool>(__br);

    // field: callback, type: Function
    gm::wire::GMFunction callback = gm::wire::codec::readFunction(__br, &__dispatch_queue);

    [__impl gamecenter_achievement_report:identifier percent_complete:percent_complete show_completion_banner:show_completion_banner callback:callback];

    return 0;
}

- (double)__EXT_NATIVE__gamecenter_achievement_reset_all:(char*)__arg_buffer arg1:(double)__arg_buffer_length
{
    gm::byteio::BufferReader __br{__arg_buffer, static_cast<size_t>(__arg_buffer_length)};

    // field: callback, type: Function
    gm::wire::GMFunction callback = gm::wire::codec::readFunction(__br, &__dispatch_queue);

    [__impl gamecenter_achievement_reset_all:callback];

    return 0;
}

- (double)__EXT_NATIVE__gamecenter_achievement_load:(char*)__arg_buffer arg1:(double)__arg_buffer_length
{
    gm::byteio::BufferReader __br{__arg_buffer, static_cast<size_t>(__arg_buffer_length)};

    // field: callback, type: Function
    gm::wire::GMFunction callback = gm::wire::codec::readFunction(__br, &__dispatch_queue);

    [__impl gamecenter_achievement_load:callback];

    return 0;
}

- (double)__EXT_NATIVE__gamecenter_access_point_set_active:(double)active
{
    bool __result = [__impl gamecenter_access_point_set_active:active];

    return static_cast<double>(__result);
}

- (double)__EXT_NATIVE__gamecenter_access_point_get_active
{
    bool __result = [__impl gamecenter_access_point_get_active];

    return static_cast<double>(__result);
}

- (double)__EXT_NATIVE__gamecenter_access_point_set_location:(char*)__arg_buffer arg1:(double)__arg_buffer_length
{
    gm::byteio::BufferReader __br{__arg_buffer, static_cast<size_t>(__arg_buffer_length)};

    // field: location, type: enum GameCenterAccessPointLocation
    gm_enums::GameCenterAccessPointLocation location = gm::wire::codec::readValue<gm_enums::GameCenterAccessPointLocation>(__br);

    bool __result = [__impl gamecenter_access_point_set_location:location];

    return static_cast<double>(__result);
}

- (double)__EXT_NATIVE__gamecenter_access_point_get_location
{
    double __result = [__impl gamecenter_access_point_get_location];

    return static_cast<double>(__result);
}

- (double)__EXT_NATIVE__gamecenter_access_point_is_presenting_game_center
{
    bool __result = [__impl gamecenter_access_point_is_presenting_game_center];

    return static_cast<double>(__result);
}

- (double)__EXT_NATIVE__gamecenter_access_point_is_visible
{
    bool __result = [__impl gamecenter_access_point_is_visible];

    return static_cast<double>(__result);
}

- (double)__EXT_NATIVE__gamecenter_access_point_set_show_highlights:(double)show
{
    bool __result = [__impl gamecenter_access_point_set_show_highlights:show];

    return static_cast<double>(__result);
}

- (double)__EXT_NATIVE__gamecenter_access_point_get_show_highlights
{
    bool __result = [__impl gamecenter_access_point_get_show_highlights];

    return static_cast<double>(__result);
}

- (double)__EXT_NATIVE__gamecenter_access_point_get_coordinate:(char*)__arg_buffer arg1:(double)__arg_buffer_length
{
    gm::byteio::BufferReader __br{__arg_buffer, static_cast<size_t>(__arg_buffer_length)};

    // field: coordinate, type: enum GameCenterAccessPointCoordinate
    gm_enums::GameCenterAccessPointCoordinate coordinate = gm::wire::codec::readValue<gm_enums::GameCenterAccessPointCoordinate>(__br);

    double __result = [__impl gamecenter_access_point_get_coordinate:coordinate];

    return static_cast<double>(__result);
}

- (double)__EXT_NATIVE__gamecenter_access_point_present_with_state:(char*)__arg_buffer arg1:(double)__arg_buffer_length
{
    gm::byteio::BufferReader __br{__arg_buffer, static_cast<size_t>(__arg_buffer_length)};

    // field: state, type: enum GameCenterViewState
    gm_enums::GameCenterViewState state = gm::wire::codec::readValue<gm_enums::GameCenterViewState>(__br);

    // field: callback, type: Function
    gm::wire::GMFunction callback = gm::wire::codec::readFunction(__br, &__dispatch_queue);

    bool __result = [__impl gamecenter_access_point_present_with_state:state callback:callback];

    return static_cast<double>(__result);
}

- (double)__EXT_NATIVE__gamecenter_access_point_present:(char*)__arg_buffer arg1:(double)__arg_buffer_length
{
    gm::byteio::BufferReader __br{__arg_buffer, static_cast<size_t>(__arg_buffer_length)};

    // field: callback, type: Function
    gm::wire::GMFunction callback = gm::wire::codec::readFunction(__br, &__dispatch_queue);

    bool __result = [__impl gamecenter_access_point_present:callback];

    return static_cast<double>(__result);
}

// Internal function used for fetching dispatched function calls to GML
- (double)__EXT_NATIVE__GMGameCenter_invocation_handler:(char*)__ret_buffer arg1:(double)__ret_buffer_length
{
    gm::byteio::BufferWriter __bw{ __ret_buffer, static_cast<size_t>(__ret_buffer_length) };
    return __dispatch_queue.fetch(__bw);
}

// Internal function used for queueing buffers to native code
- (double)__EXT_NATIVE__GMGameCenter_queue_buffer:(char*)__arg_buffer arg1:(double)__arg_buffer_length
{
    gm::wire::GMBuffer __buff{ __arg_buffer, static_cast<uint64_t>(__arg_buffer_length) };
    __buffer_queue.push(__buff);
    return 1.0;
}

@end

