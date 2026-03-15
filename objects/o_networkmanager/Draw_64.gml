/// @description Draw online multiplayer HUD info (GUI layer)

// --- Connection overlay (always visible during connecting/result) ---
if (global.net_connect_state == 1 || global.net_connect_state == 2) {
	// Actively connecting: show animated bar at bottom
	global.net_connect_timer += 1 * (60 / global.maxfps)
	
	// Dark bar across the bottom
	draw_set_alpha(0.7)
	draw_set_color(c_black)
	draw_rectangle(0, 728, 1024, 768, false)
	
	// Animated dots
	var _dots = ""
	var _dot_count = (floor(global.net_connect_timer / 30) % 4)
	repeat(_dot_count) { _dots += "." }
	
	var _label = ""
	if (global.net_connect_state == 1) { _label = "Creating lobby" }
	else { _label = "Connecting" }
	
	draw_set_font(fnt_multiplayerfont)
	draw_set_halign(fa_center)
	draw_set_valign(fa_middle)
	draw_set_alpha(1)
	draw_set_color(c_white)
	draw_text(512, 748, _label + _dots)
	
	draw_set_halign(fa_left)
	draw_set_valign(fa_top)
	draw_set_alpha(1)
}

if (global.net_connect_state == 3 || global.net_connect_state == 4) {
	// Success or failure flash
	global.net_connect_flash -= 1 * (60 / global.maxfps)
	
	var _flash_alpha = clamp(global.net_connect_flash / 60, 0, 1)
	
	if (_flash_alpha > 0) {
		// Dark bar
		draw_set_alpha(0.7 * _flash_alpha)
		draw_set_color(c_black)
		draw_rectangle(0, 728, 1024, 768, false)
		
		draw_set_font(fnt_multiplayerfont)
		draw_set_halign(fa_center)
		draw_set_valign(fa_middle)
		draw_set_alpha(_flash_alpha)
		
		if (global.net_connect_state == 3) {
			draw_set_color(c_lime)
		} else {
			draw_set_color(make_color_rgb(255, 80, 80))
		}
		draw_text(512, 748, global.net_connect_msg)
		
		draw_set_halign(fa_left)
		draw_set_valign(fa_top)
		draw_set_alpha(1)
	} else {
		// Flash done, return to idle
		global.net_connect_state = 0
	}
}

// --- Online player count (top-right corner, during gameplay) ---
if (!global.net_active) exit;
if (!net_is_main_game()) exit;

var _player_count = ds_map_size(global.net_players)
if (_player_count > 0) {
	draw_set_font(fnt_multiplayerfont)
	draw_set_halign(fa_right)
	draw_set_valign(fa_top)
	draw_set_alpha(0.6)
	
	var _ghost_count = net_get_ghost_count()
	var _text = string(_ghost_count) + "/" + string(_player_count) + " online"
	
	draw_set_color(c_black)
	draw_text(1020 + 1, 6 + 1, _text)
	draw_set_color(c_white)
	draw_text(1020, 6, _text)
	
	draw_set_alpha(1)
	draw_set_halign(fa_left)
	draw_set_valign(fa_top)
}
