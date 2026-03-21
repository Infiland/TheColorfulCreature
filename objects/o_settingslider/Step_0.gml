if global.choosesettings = slider_menu {
	// Drag logic
	if grab = true {
		x = mouse_x
		var _val = (x - beginx) / 146
		if _val < 0 { _val = 0 }
		if _val > 1 { _val = 1 }
		variable_global_set(slider_gvar, _val)
	}

	// Keyboard/D-pad volume adjustment
	var _key_left = keyboard_check(vk_left) || (gamepad_button_check(4, gp_padl)) || keyboard_check(ord("A"))
	var _key_right = keyboard_check(vk_right) || (gamepad_button_check(4, gp_padr)) || keyboard_check(ord("D"))
	if global.soundchange = slider_soundchange_id {
		var _cur = variable_global_get(slider_gvar)
		if _key_left {
			if _cur > -0.01 { variable_global_set(slider_gvar, _cur - 0.01) }
		}
		if _key_right {
			if _cur < 1.01 { variable_global_set(slider_gvar, _cur + 0.01) }
		}
		// Clamp
		var _clamped = variable_global_get(slider_gvar)
		if _clamped < 0 { variable_global_set(slider_gvar, 0) }
		if _clamped > 1 { variable_global_set(slider_gvar, 1) }
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

	// Snap position to value
	x = beginx + (variable_global_get(slider_gvar) * 146)
}

if global.choosesettings != slider_menu {
	x = lerp(x, camera_get_view_x(view_camera[0]) - 256, 0.2 * (60 / global.maxfps))
}
