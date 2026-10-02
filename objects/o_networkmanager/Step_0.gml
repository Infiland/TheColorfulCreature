if (!timing_instance_step()) exit;
/// @description Network tick: send state + receive packets + update ghosts

// Follow the player position so the smooth camera deactivation system
// never deactivates this persistent object
if (instance_exists(o_player)) {
	x = o_player.x
	y = o_player.y
}

// Process deferred join (must wait a frame after leaving a lobby)
if (global.net_pending_join != -1 && !global.net_create_pending
    && global.net_join_pending_id == -1 && timing_tick_id() > global.net_join_defer_tick) {
	net_join_lobby(global.net_pending_join);
}
// A new gameplay manager may be waiting for a cancelled old join to settle.
if (global.net_host_intent && !global.net_active && global.net_pending_join == -1
    && !global.net_create_pending && global.net_join_pending_id == -1
    && timing_tick_id() > global.net_join_defer_tick) net_host_lobby();

if (!global.net_active) exit;

// Host: keep lobby data updated with current room name
if (global.net_is_host && net_is_main_game()) {
	tcc_steam_lobby_set_data("current_room", room_get_name(room))
}

// Only send player state when we're in gameplay (main game levels)
if (net_is_main_game() && (instance_exists(o_player) || instance_exists(o_playerdead))) {
	net_send_player_state()
}

net_send_ping();

// Always receive and process packets
net_receive_packets()

// Update ghost interpolation
net_update_ghosts()
