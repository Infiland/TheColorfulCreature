if (global.choosesettings != setting_menu) { exit }
if (image_alpha = 0.5 && setting_type != STYPE.ACTION) { exit }

// DLC gate check
if dlc_gate > 0 {
	if !steam_user_owns_dlc(dlc_gate) { exit }
}

// Demo gate check
if demo_gate {
	if steam_get_app_id() = 1749610 {
		if !instance_exists(o_demoask) { instance_create(x, y, o_demoask) }
		exit
	}
}

switch (setting_type) {
	case STYPE.TOGGLE:
		var _val = variable_global_get(setting_gvar)
		if _val = 1 { variable_global_set(setting_gvar, 0) }
		else { variable_global_set(setting_gvar, 1) }
		if setting_callback != undefined { setting_callback() }
		scr_savesettings()
		break

	case STYPE.MULTI:
		if custom_cycle {
			// Handle special cycling logic
			if setting_gvar = "antialiasingsettings" {
				if global.antialiasingsettings = 4 { global.antialiasingsettings += 2 }
				global.antialiasingsettings += 2
				if global.antialiasingsettings > 8 { global.antialiasingsettings = 0 }
			} else if setting_gvar = "maxfps" {
				// maxfps stores an index 0-5
				var _idx = 0
				switch (global.maxfps) {
					case 60:  _idx = 0; break;
					case 75:  _idx = 1; break;
					case 100: _idx = 2; break;
					case 120: _idx = 3; break;
					case 144: _idx = 4; break;
					case 150: _idx = 5; break;
				}
				_idx += 1
				if _idx > 5 { _idx = 0 }
				var _fps_values = [60, 75, 100, 120, 144, 150]
				global.maxfps = _fps_values[_idx]
				game_set_speed(global.maxfps, gamespeed_fps)
				room_speed = global.maxfps
			} else {
				// Default cycle
				var _v = variable_global_get(setting_gvar) + 1
				if _v > setting_max { _v = 0 }
				variable_global_set(setting_gvar, _v)
			}
		} else {
			var _v = variable_global_get(setting_gvar) + 1
			if _v > setting_max { _v = 0 }
			variable_global_set(setting_gvar, _v)
		}
		if setting_callback != undefined { setting_callback() }
		scr_savesettings()
		break

	case STYPE.CATEGORY:
		global.choosesettings = setting_target_menu
		if setting_callback != undefined { setting_callback() }
		if instance_exists(o_animatedtext) {
			if variable_struct_exists(self, "header_label") {
				o_animatedtext.text = loc(header_label)
			}
		}
		break

	case STYPE.ACTION:
		if one_way {
			if variable_struct_exists(self, "setting_gvar") && setting_gvar != "" {
				if variable_global_get(setting_gvar) = 1 { exit }
			}
		}
		if cheat_gated && image_alpha != 1 { exit }
		if setting_callback != undefined { setting_callback() }
		scr_savesettings()
		break
}
