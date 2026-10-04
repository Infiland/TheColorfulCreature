draw_set_font(global.cool2font)
draw_set_halign(fa_left)
if instance_exists(o_fog) {draw_self()}
draw_set_color(c_white)
draw_set_halign(fa_center)
var _pause_prompt = loc(platform_mobile()
    ? "TAP_PAUSE_TO_RESUME_THE_GAME" : "PRESS_ESC_TO_RESUME_THE_GAME");
if (variable_global_exists("gp_active_device")
    && global.gp_active_device >= 0 && global.gp_active_device < 16
    && tcc_gamepad_is_connected(global.gp_active_device)) {
    var _prompt_key = platform_mobile() ? "TAP_PAUSE_OR_CONTROLLER_TO_RESUME_THE_GAME" : "PRESS_ESC_OR_CONTROLLER_TO_RESUME_THE_GAME";
    _pause_prompt = string_replace_all(loc(_prompt_key), "{BUTTON}", gamepad_button_display_name(gamepad_remap_pause_button()));
}
draw_text(512+vx,450+vy,_pause_prompt);
draw_set_halign(fa_left)

// Online Multiplayer session status
if (global.onlinemultiplayersettings == 1 && variable_global_exists("net_ready") && global.net_ready) {
	var _online_text = loc("NET_PAUSE_OFFLINE")
	draw_set_color(make_color_rgb(80, 80, 80))
	if (global.net_active) {
		draw_set_color(c_lime)
		if (global.net_is_host) {
			_online_text = string_replace(loc("NET_PAUSE_HOSTING"), "{COUNT}", string(net_member_count()))
		} else {
			_online_text = string_replace(loc("NET_PAUSE_JOINED"), "{NAME}", net_clean_name(tcc_steam_lobby_get_data("host_name")))
		}
	}
	draw_set_font(fnt_multiplayerfont)
	draw_set_halign(fa_left)
	draw_text(395+vx, 480+vy, _online_text)
	draw_set_color(c_white)
}
