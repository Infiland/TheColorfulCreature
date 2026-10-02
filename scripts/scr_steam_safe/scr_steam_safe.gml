// Native Steam calls must never run without a live Steam context.
function tcc_steam_activate_overlay(_a0) {
    if (platform_steam() && steam_initialised()) return steam_activate_overlay(_a0);
    return false;
}
function tcc_steam_activate_overlay_browser(_a0) {
    if (platform_steam() && steam_initialised()) return steam_activate_overlay_browser(_a0);
    return false;
}
function tcc_steam_activate_overlay_store(_a0) {
    if (platform_steam() && steam_initialised()) return steam_activate_overlay_store(_a0);
    return false;
}
function tcc_steam_create_leaderboard(_a0, _a1, _a2) {
    if (platform_steam() && steam_initialised()) return steam_create_leaderboard(_a0, _a1, _a2);
    return false;
}
function tcc_steam_download_friends_scores(_a0) {
    if (platform_steam() && steam_initialised()) return steam_download_friends_scores(_a0);
    return false;
}
function tcc_steam_download_scores(_a0, _a1, _a2) {
    if (platform_steam() && steam_initialised()) return steam_download_scores(_a0, _a1, _a2);
    return false;
}
function tcc_steam_download_scores_around_user(_a0, _a1, _a2) {
    if (platform_steam() && steam_initialised()) return steam_download_scores_around_user(_a0, _a1, _a2);
    return false;
}
function tcc_steam_get_app_id() {
    if (platform_steam() && steam_initialised()) return steam_get_app_id();
    return false;
}
function tcc_steam_get_number_of_current_players() {
    if (platform_steam() && steam_initialised()) return steam_get_number_of_current_players();
    return false;
}
function tcc_steam_get_persona_name() {
    if (platform_steam() && steam_initialised()) return steam_get_persona_name();
    return "";
}
function tcc_steam_get_user_avatar(_a0, _a1) {
    if (platform_steam() && steam_initialised()) return steam_get_user_avatar(_a0, _a1);
    return -1;
}
function tcc_steam_get_user_persona_name(_a0) {
    if (platform_steam() && steam_initialised()) return steam_get_user_persona_name(_a0);
    return "";
}
function tcc_steam_get_user_steam_id() {
    if (platform_steam() && steam_initialised()) return steam_get_user_steam_id();
    return int64(0);
}
function tcc_steam_image_get_rgba(_a0, _a1, _a2) {
    if (platform_steam() && steam_initialised()) return steam_image_get_rgba(_a0, _a1, _a2);
    return false;
}
function tcc_steam_image_get_size(_a0) {
    if (platform_steam() && steam_initialised()) return steam_image_get_size(_a0);
    return undefined;
}
function tcc_steam_init() {
    if (platform_steam()) return steam_init();
    return false;
}
function tcc_steam_initialised() {
    if (platform_steam()) return steam_initialised();
    return false;
}
function tcc_steam_inventory_exchange_items(_a0, _a1) {
    if (platform_steam() && steam_initialised()) return steam_inventory_exchange_items(_a0, _a1);
    return false;
}
function tcc_steam_inventory_get_all_items() {
    if (platform_steam() && steam_initialised()) return steam_inventory_get_all_items();
    return -1;
}
function tcc_steam_inventory_get_item_price(_a0) {
    if (platform_steam() && steam_initialised()) return steam_inventory_get_item_price(_a0);
    return undefined;
}
function tcc_steam_inventory_request_prices() {
    if (platform_steam() && steam_initialised()) return steam_inventory_request_prices();
    return false;
}
function tcc_steam_inventory_result_destroy(_a0) {
    if (platform_steam() && steam_initialised()) return steam_inventory_result_destroy(_a0);
    return false;
}
function tcc_steam_inventory_result_get_item_property(_a0, _a1, _a2) {
    if (platform_steam() && steam_initialised()) return steam_inventory_result_get_item_property(_a0, _a1, _a2);
    return "";
}
function tcc_steam_inventory_result_get_items(_a0) {
    if (platform_steam() && steam_initialised()) return steam_inventory_result_get_items(_a0);
    return [];
}
function tcc_steam_inventory_result_get_status(_a0) {
    if (platform_steam() && steam_initialised()) return steam_inventory_result_get_status(_a0);
    return false;
}
function tcc_steam_inventory_result_get_unix_timestamp(_a0) {
    if (platform_steam() && steam_initialised()) return steam_inventory_result_get_unix_timestamp(_a0);
    return false;
}
function tcc_steam_inventory_trigger_item_drop(_a0) {
    if (platform_steam() && steam_initialised()) return steam_inventory_trigger_item_drop(_a0);
    return false;
}
function tcc_steam_is_user_logged_on() {
    if (platform_steam() && steam_initialised()) return steam_is_user_logged_on();
    return false;
}
function tcc_steam_lobby_create(_a0, _a1) {
    if (platform_steam() && steam_initialised()) return steam_lobby_create(_a0, _a1);
    return false;
}
function tcc_steam_lobby_get_data(_a0) {
    if (platform_steam() && steam_initialised()) return steam_lobby_get_data(_a0);
    return "";
}
function tcc_steam_lobby_get_member_count() {
    if (platform_steam() && steam_initialised()) return steam_lobby_get_member_count();
    return false;
}
function tcc_steam_lobby_get_member_id(_a0) {
    if (platform_steam() && steam_initialised()) return steam_lobby_get_member_id(_a0);
    return false;
}
function tcc_steam_lobby_is_owner() {
    if (platform_steam() && steam_initialised()) return steam_lobby_is_owner();
    return false;
}
function tcc_steam_lobby_join_id(_a0) {
    if (platform_steam() && steam_initialised()) return steam_lobby_join_id(_a0);
    return false;
}
function tcc_steam_lobby_leave() {
    if (platform_steam() && steam_initialised()) return steam_lobby_leave();
    return false;
}
function tcc_steam_lobby_set_data(_a0, _a1) {
    if (platform_steam() && steam_initialised()) return steam_lobby_set_data(_a0, _a1);
    return false;
}
function tcc_steam_lobby_set_owner_id(_a0) {
    if (platform_steam() && steam_initialised()) return steam_lobby_set_owner_id(_a0);
    return false;
}
function tcc_steam_net_close_p2p_session(_a0) {
    if (platform_steam() && steam_initialised()) return steam_net_close_p2p_session(_a0);
    return false;
}
function tcc_steam_net_packet_get_data(_a0) {
    if (platform_steam() && steam_initialised()) return steam_net_packet_get_data(_a0);
    return false;
}
function tcc_steam_net_packet_get_sender_id() {
    if (platform_steam() && steam_initialised()) return steam_net_packet_get_sender_id();
    return false;
}
function tcc_steam_net_packet_get_size() {
    if (platform_steam() && steam_initialised()) return steam_net_packet_get_size();
    return false;
}
function tcc_steam_net_packet_receive() {
    if (platform_steam() && steam_initialised()) return steam_net_packet_receive();
    return false;
}
function tcc_steam_net_packet_send(_a0, _a1, _a2, _a3 = undefined) {
    if (platform_steam() && steam_initialised()) {
        // Omission retains the extension's configured default packet protocol.
        if (is_undefined(_a3)) return steam_net_packet_send(_a0, _a1, _a2);
        return steam_net_packet_send(_a0, _a1, _a2, _a3);
    }
    return false;
}
function tcc_steam_net_set_auto_accept_p2p_sessions(_a0) {
    if (platform_steam() && steam_initialised()) return steam_net_set_auto_accept_p2p_sessions(_a0);
    return false;
}
function tcc_steam_reset_all_stats_achievements() {
    if (platform_steam() && steam_initialised()) return steam_reset_all_stats_achievements();
    return false;
}
function tcc_steam_send_screenshot(_a0, _a1, _a2) {
    if (platform_steam() && steam_initialised()) return steam_send_screenshot(_a0, _a1, _a2);
    return false;
}
function tcc_steam_set_rich_presence(_a0, _a1) {
    if (platform_steam() && steam_initialised()) return steam_set_rich_presence(_a0, _a1);
    return false;
}
function tcc_steam_ugc_create_item(_a0, _a1) {
    if (platform_steam() && steam_initialised()) return steam_ugc_create_item(_a0, _a1);
    return false;
}
function tcc_steam_ugc_create_query_all(_a0, _a1, _a2) {
    if (platform_steam() && steam_initialised()) return steam_ugc_create_query_all(_a0, _a1, _a2);
    return -1;
}
function tcc_steam_ugc_get_item_install_info(_a0, _a1) {
    if (platform_steam() && steam_initialised()) return steam_ugc_get_item_install_info(_a0, _a1);
    return false;
}
function tcc_steam_ugc_get_item_update_info(_a0, _a1) {
    if (platform_steam() && steam_initialised()) return steam_ugc_get_item_update_info(_a0, _a1);
    return false;
}
function tcc_steam_ugc_get_item_update_progress(_a0, _a1) {
    if (platform_steam() && steam_initialised()) return steam_ugc_get_item_update_progress(_a0, _a1);
    return false;
}
function tcc_steam_ugc_get_subscribed_items(_a0) {
    if (platform_steam() && steam_initialised()) return steam_ugc_get_subscribed_items(_a0);
    return false;
}
function tcc_steam_ugc_num_subscribed_items() {
    if (platform_steam() && steam_initialised()) return steam_ugc_num_subscribed_items();
    return false;
}
function tcc_steam_ugc_query_set_search_text(_a0, _a1) {
    if (platform_steam() && steam_initialised()) return steam_ugc_query_set_search_text(_a0, _a1);
    return false;
}
function tcc_steam_ugc_request_item_details(_a0, _a1) {
    if (platform_steam() && steam_initialised()) return steam_ugc_request_item_details(_a0, _a1);
    return false;
}
function tcc_steam_ugc_send_query(_a0) {
    if (platform_steam() && steam_initialised()) return steam_ugc_send_query(_a0);
    return false;
}
function tcc_steam_ugc_set_item_content(_a0, _a1) {
    if (platform_steam() && steam_initialised()) return steam_ugc_set_item_content(_a0, _a1);
    return false;
}
function tcc_steam_ugc_set_item_description(_a0, _a1) {
    if (platform_steam() && steam_initialised()) return steam_ugc_set_item_description(_a0, _a1);
    return false;
}
function tcc_steam_ugc_set_item_preview(_a0, _a1) {
    if (platform_steam() && steam_initialised()) return steam_ugc_set_item_preview(_a0, _a1);
    return false;
}
function tcc_steam_ugc_set_item_tags(_a0, _a1) {
    if (platform_steam() && steam_initialised()) return steam_ugc_set_item_tags(_a0, _a1);
    return false;
}
function tcc_steam_ugc_set_item_title(_a0, _a1) {
    if (platform_steam() && steam_initialised()) return steam_ugc_set_item_title(_a0, _a1);
    return false;
}
function tcc_steam_ugc_set_item_visibility(_a0, _a1) {
    if (platform_steam() && steam_initialised()) return steam_ugc_set_item_visibility(_a0, _a1);
    return false;
}
function tcc_steam_ugc_start_item_update(_a0, _a1) {
    if (platform_steam() && steam_initialised()) return steam_ugc_start_item_update(_a0, _a1);
    return -1;
}
function tcc_steam_ugc_submit_item_update(_a0, _a1) {
    if (platform_steam() && steam_initialised()) return steam_ugc_submit_item_update(_a0, _a1);
    return false;
}
function tcc_steam_ugc_subscribe_item(_a0) {
    if (platform_steam() && steam_initialised()) return steam_ugc_subscribe_item(_a0);
    return false;
}
function tcc_steam_ugc_unsubscribe_item(_a0) {
    if (platform_steam() && steam_initialised()) return steam_ugc_unsubscribe_item(_a0);
    return false;
}
function tcc_steam_update() {
    if (platform_steam() && steam_initialised()) return steam_update();
    return false;
}
function tcc_steam_user_installed_dlc(_a0) {
    if (platform_steam() && steam_initialised()) return steam_user_installed_dlc(_a0);
    return false;
}
function tcc_steam_user_owns_dlc(_a0) {
    if (platform_steam() && steam_initialised()) return steam_user_owns_dlc(_a0);
    return false;
}
