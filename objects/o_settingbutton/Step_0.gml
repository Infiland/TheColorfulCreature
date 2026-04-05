// Animate x position based on which submenu is active
var _cam_x = camera_get_view_x(view_camera[0])
var _lerp_speed = 0.2 * (60 / global.maxfps)

if global.choosesettings != setting_menu {
	x = lerp(x, _cam_x - 256, _lerp_speed)
} else {
	x = lerp(x, _cam_x + setting_col, _lerp_speed)
}

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
	if !steam_user_owns_dlc(dlc_gate) { image_alpha = 0.5 }
}
