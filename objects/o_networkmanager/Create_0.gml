/// @description Initialize Online Multiplayer Network Manager

// This object is persistent and handles all Steam lobby + P2P networking
// It auto-creates a lobby when the player starts the main game

show_debug_message("[NET] Network Manager created")

// Ensure net globals are ready
if (!variable_global_exists("net_active") || !global.net_active) {
	net_init()
}

// Auto-host a lobby if the setting is enabled, Steam is available,
// and we don't have a pending join (i.e., we're not joining someone else)
if (global.onlinemultiplayersettings == 1 && steam_initialised()) {
	if (!global.net_active && global.net_pending_join == -1) {
		net_host_lobby()
	}
}

// Auto-accept P2P sessions from lobby members
steam_net_set_auto_accept_p2p_sessions(true)

depth = 2  // Draw ghosts behind o_player (which is at depth 1)
