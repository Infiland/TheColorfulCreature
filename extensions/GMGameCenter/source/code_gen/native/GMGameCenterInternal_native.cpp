// ##### extgen :: Auto-generated file do not edit!! #####

#include "GMGameCenterInternal_native.h"
#include "GMGameCenterInternal_exports.h"

using namespace gm_structs;
using namespace gm::wire::codec;

static gm::runtime::DispatchQueue __dispatch_queue;

// Internal function used for fetching dispatched function calls to GML
GMEXPORT double __EXT_NATIVE__GMGameCenter_invocation_handler(char* __ret_buffer, double __ret_buffer_length)
{
    gm::byteio::BufferWriter __bw{ __ret_buffer, static_cast<size_t>(__ret_buffer_length) };
    return __dispatch_queue.fetch(__bw);
}

static std::queue<gm::wire::GMBuffer> __buffer_queue;

// Internal function used for queueing buffers to native code
GMEXPORT double __EXT_NATIVE__GMGameCenter_queue_buffer(char* __arg_buffer, double __arg_buffer_length)
{
    gm::wire::GMBuffer __buff{__arg_buffer, static_cast<uint64_t>(__arg_buffer_length)};
    __buffer_queue.push(__buff);

    return 1.0;
}

GMEXPORT double __EXT_NATIVE__gamecenter_view_callback_subscribe(char* __arg_buffer, double __arg_buffer_length)
{
    gm::byteio::BufferReader __br{__arg_buffer, static_cast<size_t>(__arg_buffer_length)};

    // field: callback, type: Function
    gm::wire::GMFunction callback = gm::wire::codec::readFunction(__br, &__dispatch_queue);

    gamecenter_view_callback_subscribe(callback);
    return 0;
}

GMEXPORT double __EXT_NATIVE__gamecenter_present_view_achievement(char* achievement_id)
{
    auto&& __result = gamecenter_present_view_achievement(achievement_id);
    return static_cast<double>(__result);
}

GMEXPORT double __EXT_NATIVE__gamecenter_present_view_leaderboard(char* __arg_buffer, double __arg_buffer_length)
{
    gm::byteio::BufferReader __br{__arg_buffer, static_cast<size_t>(__arg_buffer_length)};

    // field: leaderboard_id, type: String
    std::string_view leaderboard_id = gm::wire::codec::readValue<std::string_view>(__br);

    // field: time_scope, type: enum GameCenterLeaderboardTimeScope
    gm_enums::GameCenterLeaderboardTimeScope time_scope = gm::wire::codec::readValue<gm_enums::GameCenterLeaderboardTimeScope>(__br);

    // field: player_scope, type: enum GameCenterLeaderboardPlayerScope
    gm_enums::GameCenterLeaderboardPlayerScope player_scope = gm::wire::codec::readValue<gm_enums::GameCenterLeaderboardPlayerScope>(__br);

    auto&& __result = gamecenter_present_view_leaderboard(leaderboard_id, time_scope, player_scope);
    return static_cast<double>(__result);
}

GMEXPORT double __EXT_NATIVE__gamecenter_local_player_authenticate(char* __arg_buffer, double __arg_buffer_length)
{
    gm::byteio::BufferReader __br{__arg_buffer, static_cast<size_t>(__arg_buffer_length)};

    // field: callback, type: Function
    gm::wire::GMFunction callback = gm::wire::codec::readFunction(__br, &__dispatch_queue);

    gamecenter_local_player_authenticate(callback);
    return 0;
}

GMEXPORT double __EXT_NATIVE__gamecenter_local_player_is_authenticated()
{
    auto&& __result = gamecenter_local_player_is_authenticated();
    return static_cast<double>(__result);
}

GMEXPORT double __EXT_NATIVE__gamecenter_local_player_is_underage()
{
    auto&& __result = gamecenter_local_player_is_underage();
    return static_cast<double>(__result);
}

GMEXPORT double __EXT_NATIVE__gamecenter_local_player_is_multiplayer_gaming_restricted()
{
    auto&& __result = gamecenter_local_player_is_multiplayer_gaming_restricted();
    return static_cast<double>(__result);
}

GMEXPORT double __EXT_NATIVE__gamecenter_local_player_is_personalized_communication_restricted()
{
    auto&& __result = gamecenter_local_player_is_personalized_communication_restricted();
    return static_cast<double>(__result);
}

GMEXPORT double __EXT_NATIVE__gamecenter_local_player_get_info(char* __ret_buffer, double __ret_buffer_length)
{
    auto&& __result = gamecenter_local_player_get_info();
    gm::byteio::BufferWriter __bw{__ret_buffer, static_cast<size_t>(__ret_buffer_length)};

    // return: __result, type: struct GameCenterPlayer
    gm::wire::codec::writeValue(__bw, __result);
    return 0;
}

GMEXPORT double __EXT_NATIVE__gamecenter_saved_games_callback_subscribe(char* __arg_buffer, double __arg_buffer_length)
{
    gm::byteio::BufferReader __br{__arg_buffer, static_cast<size_t>(__arg_buffer_length)};

    // field: callback, type: Function
    gm::wire::GMFunction callback = gm::wire::codec::readFunction(__br, &__dispatch_queue);

    gamecenter_saved_games_callback_subscribe(callback);
    return 0;
}

GMEXPORT double __EXT_NATIVE__gamecenter_saved_games_fetch(char* __arg_buffer, double __arg_buffer_length)
{
    gm::byteio::BufferReader __br{__arg_buffer, static_cast<size_t>(__arg_buffer_length)};

    // field: callback, type: Function
    gm::wire::GMFunction callback = gm::wire::codec::readFunction(__br, &__dispatch_queue);

    gamecenter_saved_games_fetch(callback);
    return 0;
}

GMEXPORT double __EXT_NATIVE__gamecenter_saved_games_save(char* __arg_buffer, double __arg_buffer_length)
{
    gm::byteio::BufferReader __br{__arg_buffer, static_cast<size_t>(__arg_buffer_length)};

    // field: name, type: String
    std::string_view name = gm::wire::codec::readValue<std::string_view>(__br);

    // field: data, type: Buffer
    gm::wire::GMBuffer data = __buffer_queue.front();
    __buffer_queue.pop();

    // field: callback, type: Function
    gm::wire::GMFunction callback = gm::wire::codec::readFunction(__br, &__dispatch_queue);

    gamecenter_saved_games_save(name, data, callback);
    return 0;
}

GMEXPORT double __EXT_NATIVE__gamecenter_saved_games_delete(char* __arg_buffer, double __arg_buffer_length)
{
    gm::byteio::BufferReader __br{__arg_buffer, static_cast<size_t>(__arg_buffer_length)};

    // field: name, type: String
    std::string_view name = gm::wire::codec::readValue<std::string_view>(__br);

    // field: callback, type: Function
    gm::wire::GMFunction callback = gm::wire::codec::readFunction(__br, &__dispatch_queue);

    gamecenter_saved_games_delete(name, callback);
    return 0;
}

GMEXPORT double __EXT_NATIVE__gamecenter_saved_games_data_request(char* __arg_buffer, double __arg_buffer_length)
{
    gm::byteio::BufferReader __br{__arg_buffer, static_cast<size_t>(__arg_buffer_length)};

    // field: name, type: String
    std::string_view name = gm::wire::codec::readValue<std::string_view>(__br);

    // field: callback, type: Function
    gm::wire::GMFunction callback = gm::wire::codec::readFunction(__br, &__dispatch_queue);

    gamecenter_saved_games_data_request(name, callback);
    return 0;
}

GMEXPORT double __EXT_NATIVE__gamecenter_saved_games_data_fetch(char* __arg_buffer, double __arg_buffer_length)
{
    gm::byteio::BufferReader __br{__arg_buffer, static_cast<size_t>(__arg_buffer_length)};

    // field: handle_id, type: Float64
    double handle_id = gm::wire::codec::readValue<double>(__br);

    // field: data, type: Buffer
    gm::wire::GMBuffer data = __buffer_queue.front();
    __buffer_queue.pop();

    auto&& __result = gamecenter_saved_games_data_fetch(handle_id, data);
    return static_cast<double>(__result);
}

GMEXPORT double __EXT_NATIVE__gamecenter_saved_games_data_release(double handle_id)
{
    auto&& __result = gamecenter_saved_games_data_release(static_cast<double>(handle_id));
    return static_cast<double>(__result);
}

GMEXPORT double __EXT_NATIVE__gamecenter_saved_games_resolve_conflict(char* __arg_buffer, double __arg_buffer_length)
{
    gm::byteio::BufferReader __br{__arg_buffer, static_cast<size_t>(__arg_buffer_length)};

    // field: conflict_id, type: Float64
    double conflict_id = gm::wire::codec::readValue<double>(__br);

    // field: data, type: Buffer
    gm::wire::GMBuffer data = __buffer_queue.front();
    __buffer_queue.pop();

    // field: callback, type: Function
    gm::wire::GMFunction callback = gm::wire::codec::readFunction(__br, &__dispatch_queue);

    gamecenter_saved_games_resolve_conflict(conflict_id, data, callback);
    return 0;
}

GMEXPORT double __EXT_NATIVE__gamecenter_leaderboard_submit(char* __arg_buffer, double __arg_buffer_length)
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

    gamecenter_leaderboard_submit(leaderboard_id, score, context, callback);
    return 0;
}

GMEXPORT double __EXT_NATIVE__gamecenter_leaderboard_load(char* __arg_buffer, double __arg_buffer_length)
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

    gamecenter_leaderboard_load(leaderboard_id, time_scope, range_start, range_count, player_scope, callback);
    return 0;
}

GMEXPORT double __EXT_NATIVE__gamecenter_achievement_report(char* __arg_buffer, double __arg_buffer_length)
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

    gamecenter_achievement_report(identifier, percent_complete, show_completion_banner, callback);
    return 0;
}

GMEXPORT double __EXT_NATIVE__gamecenter_achievement_reset_all(char* __arg_buffer, double __arg_buffer_length)
{
    gm::byteio::BufferReader __br{__arg_buffer, static_cast<size_t>(__arg_buffer_length)};

    // field: callback, type: Function
    gm::wire::GMFunction callback = gm::wire::codec::readFunction(__br, &__dispatch_queue);

    gamecenter_achievement_reset_all(callback);
    return 0;
}

GMEXPORT double __EXT_NATIVE__gamecenter_achievement_load(char* __arg_buffer, double __arg_buffer_length)
{
    gm::byteio::BufferReader __br{__arg_buffer, static_cast<size_t>(__arg_buffer_length)};

    // field: callback, type: Function
    gm::wire::GMFunction callback = gm::wire::codec::readFunction(__br, &__dispatch_queue);

    gamecenter_achievement_load(callback);
    return 0;
}

GMEXPORT double __EXT_NATIVE__gamecenter_access_point_set_active(double active)
{
    auto&& __result = gamecenter_access_point_set_active(static_cast<bool>(active));
    return static_cast<double>(__result);
}

GMEXPORT double __EXT_NATIVE__gamecenter_access_point_get_active()
{
    auto&& __result = gamecenter_access_point_get_active();
    return static_cast<double>(__result);
}

GMEXPORT double __EXT_NATIVE__gamecenter_access_point_set_location(char* __arg_buffer, double __arg_buffer_length)
{
    gm::byteio::BufferReader __br{__arg_buffer, static_cast<size_t>(__arg_buffer_length)};

    // field: location, type: enum GameCenterAccessPointLocation
    gm_enums::GameCenterAccessPointLocation location = gm::wire::codec::readValue<gm_enums::GameCenterAccessPointLocation>(__br);

    auto&& __result = gamecenter_access_point_set_location(location);
    return static_cast<double>(__result);
}

GMEXPORT double __EXT_NATIVE__gamecenter_access_point_get_location()
{
    auto&& __result = gamecenter_access_point_get_location();
    return static_cast<double>(__result);
}

GMEXPORT double __EXT_NATIVE__gamecenter_access_point_is_presenting_game_center()
{
    auto&& __result = gamecenter_access_point_is_presenting_game_center();
    return static_cast<double>(__result);
}

GMEXPORT double __EXT_NATIVE__gamecenter_access_point_is_visible()
{
    auto&& __result = gamecenter_access_point_is_visible();
    return static_cast<double>(__result);
}

GMEXPORT double __EXT_NATIVE__gamecenter_access_point_set_show_highlights(double show)
{
    auto&& __result = gamecenter_access_point_set_show_highlights(static_cast<bool>(show));
    return static_cast<double>(__result);
}

GMEXPORT double __EXT_NATIVE__gamecenter_access_point_get_show_highlights()
{
    auto&& __result = gamecenter_access_point_get_show_highlights();
    return static_cast<double>(__result);
}

GMEXPORT double __EXT_NATIVE__gamecenter_access_point_get_coordinate(char* __arg_buffer, double __arg_buffer_length)
{
    gm::byteio::BufferReader __br{__arg_buffer, static_cast<size_t>(__arg_buffer_length)};

    // field: coordinate, type: enum GameCenterAccessPointCoordinate
    gm_enums::GameCenterAccessPointCoordinate coordinate = gm::wire::codec::readValue<gm_enums::GameCenterAccessPointCoordinate>(__br);

    auto&& __result = gamecenter_access_point_get_coordinate(coordinate);
    return static_cast<double>(__result);
}

GMEXPORT double __EXT_NATIVE__gamecenter_access_point_present_with_state(char* __arg_buffer, double __arg_buffer_length)
{
    gm::byteio::BufferReader __br{__arg_buffer, static_cast<size_t>(__arg_buffer_length)};

    // field: state, type: enum GameCenterViewState
    gm_enums::GameCenterViewState state = gm::wire::codec::readValue<gm_enums::GameCenterViewState>(__br);

    // field: callback, type: Function
    gm::wire::GMFunction callback = gm::wire::codec::readFunction(__br, &__dispatch_queue);

    auto&& __result = gamecenter_access_point_present_with_state(state, callback);
    return static_cast<double>(__result);
}

GMEXPORT double __EXT_NATIVE__gamecenter_access_point_present(char* __arg_buffer, double __arg_buffer_length)
{
    gm::byteio::BufferReader __br{__arg_buffer, static_cast<size_t>(__arg_buffer_length)};

    // field: callback, type: Function
    gm::wire::GMFunction callback = gm::wire::codec::readFunction(__br, &__dispatch_queue);

    auto&& __result = gamecenter_access_point_present(callback);
    return static_cast<double>(__result);
}

