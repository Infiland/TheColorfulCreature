/// @description Network tick: send state + receive packets + update ghosts

// Follow the player position so the smooth camera deactivation system
// never deactivates this persistent object
if (instance_exists(o_player)) {
	x = o_player.x
	y = o_player.y
}

// Process deferred join (must wait a frame after leaving a lobby)
if (global.net_pending_join != -1) {
	var _join_id = global.net_pending_join
	global.net_pending_join = -1
	net_join_lobby(_join_id)
}

if (!global.net_active) exit;

// Host: keep lobby data updated with current room name
if (global.net_is_host && net_is_main_game()) {
	steam_lobby_set_data("current_room", room_get_name(room))
}

// Only send player state when we're in gameplay (main game levels)
if (net_is_main_game() && instance_exists(o_player)) {
	net_send_player_state()
}

// Always receive and process packets
net_receive_packets()

// Update ghost interpolation
net_update_ghosts()
