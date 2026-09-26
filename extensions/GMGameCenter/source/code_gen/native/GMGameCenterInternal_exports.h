// ##### extgen :: Auto-generated file do not edit!! #####

#pragma once
#include "core/GMExtUtils.h"

// Internal function used for fetching dispatched function calls to GML
GMEXPORT double __EXT_NATIVE__GMGameCenter_invocation_handler(char* __ret_buffer, double __ret_buffer_length);

// Internal function used for queueing buffers to native code
GMEXPORT double __EXT_NATIVE__GMGameCenter_queue_buffer(char* __arg_buffer, double __arg_buffer_length);

GMEXPORT double __EXT_NATIVE__gamecenter_view_callback_subscribe(char* __arg_buffer, double __arg_buffer_length);
GMEXPORT double __EXT_NATIVE__gamecenter_present_view_achievement(char* achievement_id);
GMEXPORT double __EXT_NATIVE__gamecenter_present_view_leaderboard(char* __arg_buffer, double __arg_buffer_length);
GMEXPORT double __EXT_NATIVE__gamecenter_local_player_authenticate(char* __arg_buffer, double __arg_buffer_length);
GMEXPORT double __EXT_NATIVE__gamecenter_local_player_is_authenticated();
GMEXPORT double __EXT_NATIVE__gamecenter_local_player_is_underage();
GMEXPORT double __EXT_NATIVE__gamecenter_local_player_is_multiplayer_gaming_restricted();
GMEXPORT double __EXT_NATIVE__gamecenter_local_player_is_personalized_communication_restricted();
GMEXPORT double __EXT_NATIVE__gamecenter_local_player_get_info(char* __ret_buffer, double __ret_buffer_length);
GMEXPORT double __EXT_NATIVE__gamecenter_saved_games_callback_subscribe(char* __arg_buffer, double __arg_buffer_length);
GMEXPORT double __EXT_NATIVE__gamecenter_saved_games_fetch(char* __arg_buffer, double __arg_buffer_length);
GMEXPORT double __EXT_NATIVE__gamecenter_saved_games_save(char* __arg_buffer, double __arg_buffer_length);
GMEXPORT double __EXT_NATIVE__gamecenter_saved_games_delete(char* __arg_buffer, double __arg_buffer_length);
GMEXPORT double __EXT_NATIVE__gamecenter_saved_games_data_request(char* __arg_buffer, double __arg_buffer_length);
GMEXPORT double __EXT_NATIVE__gamecenter_saved_games_data_fetch(char* __arg_buffer, double __arg_buffer_length);
GMEXPORT double __EXT_NATIVE__gamecenter_saved_games_data_release(double handle_id);
GMEXPORT double __EXT_NATIVE__gamecenter_saved_games_resolve_conflict(char* __arg_buffer, double __arg_buffer_length);
GMEXPORT double __EXT_NATIVE__gamecenter_leaderboard_submit(char* __arg_buffer, double __arg_buffer_length);
GMEXPORT double __EXT_NATIVE__gamecenter_leaderboard_load(char* __arg_buffer, double __arg_buffer_length);
GMEXPORT double __EXT_NATIVE__gamecenter_achievement_report(char* __arg_buffer, double __arg_buffer_length);
GMEXPORT double __EXT_NATIVE__gamecenter_achievement_reset_all(char* __arg_buffer, double __arg_buffer_length);
GMEXPORT double __EXT_NATIVE__gamecenter_achievement_load(char* __arg_buffer, double __arg_buffer_length);
GMEXPORT double __EXT_NATIVE__gamecenter_access_point_set_active(double active);
GMEXPORT double __EXT_NATIVE__gamecenter_access_point_get_active();
GMEXPORT double __EXT_NATIVE__gamecenter_access_point_set_location(char* __arg_buffer, double __arg_buffer_length);
GMEXPORT double __EXT_NATIVE__gamecenter_access_point_get_location();
GMEXPORT double __EXT_NATIVE__gamecenter_access_point_is_presenting_game_center();
GMEXPORT double __EXT_NATIVE__gamecenter_access_point_is_visible();
GMEXPORT double __EXT_NATIVE__gamecenter_access_point_set_show_highlights(double show);
GMEXPORT double __EXT_NATIVE__gamecenter_access_point_get_show_highlights();
GMEXPORT double __EXT_NATIVE__gamecenter_access_point_get_coordinate(char* __arg_buffer, double __arg_buffer_length);
GMEXPORT double __EXT_NATIVE__gamecenter_access_point_present_with_state(char* __arg_buffer, double __arg_buffer_length);
GMEXPORT double __EXT_NATIVE__gamecenter_access_point_present(char* __arg_buffer, double __arg_buffer_length);

