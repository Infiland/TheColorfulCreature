// net_game_restart keeps the session; the next boot reuses it (net_init returns early).
if (variable_global_exists("net_restarting") && global.net_restarting) {
	global.net_restarting = false;
	exit;
}
// Leaves the lobby (handing ownership over) and frees every buffer and map.
net_cleanup();
