if global.choosesettings = slider_menu {
	// Manual click detection over full track area (sprite mask is too small)
	var _mx = mouse_x
	var _my = mouse_y
	var _in_track = (_mx >= beginx - 8 && _mx <= endx + 8 && _my >= y - 4 && _my <= y + 20)

	if _in_track {
		global.infosettings = slider_info_id
		if device_mouse_check_button_pressed(0, mb_left) {
			grab = true
			global.soundchange = slider_soundchange_id
		}
	} else if !grab {
		// Only clear hover if not currently dragging
		if global.infosettings = slider_info_id {
			global.infosettings = 0
		}
	}

	// Drag logic
	if grab = true {
		x = mouse_x
		var _normalized = (x - beginx) / 146
		if _normalized < 0 { _normalized = 0 }
		if _normalized > 1 { _normalized = 1 }
		var _val = slider_min + _normalized * (slider_max - slider_min)
		if slider_integer { _val = round(_val) }
		variable_global_set(slider_gvar, _val)
	}

	// Keyboard/D-pad adjustment
	var _key_left = keyboard_check(vk_left) || (gamepad_button_check(4, gp_padl)) || keyboard_check(ord("A"))
	var _key_right = keyboard_check(vk_right) || (gamepad_button_check(4, gp_padr)) || keyboard_check(ord("D"))
	if global.soundchange = slider_soundchange_id {
		var _cur = variable_global_get(slider_gvar)
		var _step = slider_integer ? max(1, ceil((slider_max - slider_min) / 100)) : 0.01
		if _key_left {
			variable_global_set(slider_gvar, max(_cur - _step, slider_min))
		}
		if _key_right {
			variable_global_set(slider_gvar, min(_cur + _step, slider_max))
		}
		if slider_integer { variable_global_set(slider_gvar, round(variable_global_get(slider_gvar))) }
	}
	if keyboard_check_released(vk_left) or gamepad_button_check_released(0, gp_padl) or keyboard_check_released(ord("A")) or keyboard_check_released(vk_right) or gamepad_button_check_released(0, gp_padr) or keyboard_check_released(ord("D")) {
		scr_savesettings()
	}

	// Real-time audio updates
	if slider_gvar = "musicvolume" {
		audio_sound_gain(m_mainmenu, global.musicvolume, 1)
	}
	if slider_gvar = "mastervolume" {
		audio_master_gain(global.mastervolume)
	}

	// Gamepad support
	if global.infosettings = slider_info_id {
		if gamepad_button_check_pressed(0, gp_face1) {
			event_perform(ev_mouse, ev_left_press)
		}
	}

	// Release drag
	if device_mouse_check_button_released(0, mb_left) || gamepad_button_check_released(0, gp_face1) {
		grab = false
		global.soundchange = 0
	}

	// Snap position to value (normalized)
	var _normalized = (slider_max != slider_min) ? (variable_global_get(slider_gvar) - slider_min) / (slider_max - slider_min) : 0
	x = beginx + (_normalized * 146)
}

if global.choosesettings != slider_menu {
	x = lerp(x, camera_get_view_x(view_camera[0]) - 256, 0.2 * (60 / global.maxfps))
}
