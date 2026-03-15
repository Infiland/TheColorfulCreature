/// @description Draw ghost players in gameplay

if (!global.net_active) exit;

// Only draw ghosts during main gameplay
if (net_is_main_game()) {
	net_draw_ghosts()
}
