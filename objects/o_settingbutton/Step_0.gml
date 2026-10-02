if (!timing_instance_step()) exit;
// Animate x position based on which submenu is active
var _cam_x = camera_get_view_x(view_camera[0])
var _lerp_speed = 0.2 * (60 / global.maxfps)

if global.choosesettings != setting_menu {
	x = lerp(x, _cam_x - 256, _lerp_speed)
} else {
	x = lerp(x, _cam_x + setting_col, _lerp_speed)
}

image_alpha = 1;

// Gated settings: gray out when disabled
if gated {
	image_alpha = 0.5
}

// Cheat-gated buttons: dim when cheats are off
if cheat_gated {
	if global.cheats = 0 { image_alpha = 0.5 }
	else { image_alpha = 1 }
}

// One-way toggle (turn on cheats): dim after activation
if one_way {
	if variable_struct_exists(self, "setting_gvar") && setting_gvar != "" {
		if variable_global_get(setting_gvar) = 1 { image_alpha = 0.5 }
	}
}

// DLC gate check
if dlc_gate > 0 {
	if !tcc_steam_user_owns_dlc(dlc_gate) { image_alpha = 0.5 }
}

if (!settings_fps_input_blocked() && global.choosesettings == setting_menu && mouseon) {
    var _device = gamepad_remap_active_device(true);
    if (_device >= 0 && tcc_gamepad_button_check_pressed(_device, gp_face1)) event_perform(ev_mouse, ev_left_press);
}
