if (!timing_instance_step()) exit;
/// @description Session tracking, lobby lifecycle, packets and ghosts

// Follow the player position so the smooth camera deactivation system
// never deactivates this persistent object
if (instance_exists(o_player)) {
	x = o_player.x
	y = o_player.y
}

net_session_update();
net_tick();

for (var _i = array_length(global.net_notices) - 1; _i >= 0; --_i) {
	global.net_notices[_i].timer -= 1;
	if (global.net_notices[_i].timer <= 0) array_delete(global.net_notices, _i, 1);
}
