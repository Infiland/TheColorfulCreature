if (!timing_instance_step()) exit;
if (platform_mobile()) {
    if (mobile_page_direction != 0) {
        settings_mobile_layout(global.choosesettings, 0);
        visible = settings_mobile_page_count() > 1;
        x = camera_get_view_x(view_camera[0]) + (visible ? (mobile_page_direction < 0 ? 256 : 552) : -2000);
        y = camera_get_view_y(view_camera[0]) + 522;
        image_xscale = 43.2; image_yscale = 21.6;
        mobile_card_width = 216; mobile_card_height = 108;
        setting_menu = global.choosesettings;
        if (!visible) mouseon = false;
    } else settings_mobile_layout(setting_menu, mobile_settings_slot);
} else {
    var _cam_x = camera_get_view_x(view_camera[0]);
    var _lerp_speed = 0.2 * (60 / global.maxfps);
    x = lerp(x, _cam_x + (global.choosesettings == setting_menu ? setting_col : -256), _lerp_speed);
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
