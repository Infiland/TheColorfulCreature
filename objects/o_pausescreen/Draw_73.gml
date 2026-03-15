draw_set_font(global.cool2font)
draw_set_halign(fa_left)
if instance_exists(o_fog) {draw_self()}
draw_set_color(c_white)
draw_text(395+vx,450+vy,loc("PRESS_ESC_TO_RESUME_THE_GAME"));

// Online Multiplayer hosting status
if (global.onlinemultiplayersettings == 1) {
	var _hosting_text = ""
	if (global.net_active && global.net_is_host) {
		draw_set_color(c_lime)
		var _count = ds_map_size(global.net_players)
		_hosting_text = "HOSTING (" + string(_count) + " connected)"
	} else if (global.net_active && !global.net_is_host) {
		draw_set_color(c_lime)
		_hosting_text = "CONNECTED"
	} else {
		draw_set_color(make_color_rgb(80, 80, 80))
		_hosting_text = "NOT HOSTING"
	}
	draw_set_font(fnt_multiplayerfont)
	draw_set_halign(fa_left)
	draw_text(395+vx, 480+vy, _hosting_text)
	draw_set_color(c_white)
}