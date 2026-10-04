/// @description Online Multiplayer Network Manager

// Created once at boot and persistent for the whole game. It owns the Steam
// lobby (the player's online session), joins from the Steam overlay or the
// Friends panel in any room, follows the host between modes and draws ghosts.
net_init();
show_debug_message("[NET] Network Manager created");

depth = 2  // Draw ghosts behind o_player (which is at depth 1)
