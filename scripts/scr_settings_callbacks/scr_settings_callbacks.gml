// Settings callbacks and shared spawning logic.

/// @function scr_spawn_settings_buttons()
/// @description Spawns all data-driven settings buttons, sliders, controls and language buttons
function scr_spawn_settings_buttons() {
	var _defs = scr_settings_definitions()
	var _cx = camera_get_view_x(view_camera[0])
	var _cy = camera_get_view_y(view_camera[0])
	global.soundchange = 0

	for (var i = 0; i < array_length(_defs); i++) {
		var _d = _defs[i]

		if _d.type = STYPE.SLIDER {
			var _inst = instance_create(_cx, _cy + 160 + (_d.row * 64), o_settingslider)
			slider_apply_from_def(_inst, _d)
		} else {
			var _inst = instance_create(_cx - 256, _cy + 160 + (_d.row * 64), o_settingbutton)
			settings_apply_from_def(_inst, _d)
		}
	}

	// Controls (for-loop pattern)
	for (var i = 0; i < 6; i++) {
		var _ctrl = instance_create(_cx - 128, _cy + 160 + 80 * i, o_controlsbuttonsettings)
		with _ctrl {
			controls = i
		}
	}

	var _dkb
	if os_type != os_android {
		_dkb = instance_create(_cx - 128, _cy + 640, o_defaultkeysbuttonsetings)
	} else {
		_dkb = instance_create(_cx - 128, _cy + 160, o_defaultkeysbuttonsetings)
	}
	with _dkb {
		xscale = 0.4
		yscale = 0.4
		width = 2
		image_xscale = 24.2
		image_yscale = 10.78844
	}

	// Languages
	for (var i2 = 0; i2 <= 17; i2++) {
		var _lang = instance_create(_cx - 256, _cy + 160 + ((64 * i2) - (floor(i2 / 8) * 512)), o_changelanguagesettings)
		with _lang {
			depth = -101
			image_xscale = 37.7
			image_yscale = 10
			language = i2
			xscale = 0.7
			yscale = 0.7
			width = 3
		}
	}
}

/// @function settings_apply_from_def(inst, def)
/// @description Applies a settings definition struct to an o_settingbutton instance
function settings_apply_from_def(_inst, _def) {
	with (_inst) {
		setting_type = _def.type
		setting_menu = _def.menu
		setting_col = _def.col
		setting_row = _def.row
		setting_label = _def.label
		setting_info_id = variable_struct_exists(_def, "info") ? _def.info : -1

		if variable_struct_exists(_def, "gvar") { setting_gvar = _def.gvar }
		if variable_struct_exists(_def, "max_val") { setting_max = _def.max_val }
		if variable_struct_exists(_def, "options") { setting_options = _def.options }
		if variable_struct_exists(_def, "target_menu") { setting_target_menu = _def.target_menu }
		if variable_struct_exists(_def, "callback") { setting_callback = _def.callback }
		if variable_struct_exists(_def, "custom_cycle") { custom_cycle = _def.custom_cycle }
		if variable_struct_exists(_def, "cheat_gated") { cheat_gated = _def.cheat_gated }
		if variable_struct_exists(_def, "one_way") { one_way = _def.one_way }
		if variable_struct_exists(_def, "gated") { gated = _def.gated }
		if variable_struct_exists(_def, "dlc_gate") { dlc_gate = _def.dlc_gate }
		if variable_struct_exists(_def, "demo_gate") { demo_gate = _def.demo_gate }
		if variable_struct_exists(_def, "header_label") { header_label = _def.header_label }
		if variable_struct_exists(_def, "use_loc") { use_loc = _def.use_loc }
	}
}

/// @function slider_apply_from_def(inst, def)
/// @description Applies a settings definition struct to an o_settingslider instance
function slider_apply_from_def(_inst, _def) {
	with (_inst) {
		slider_gvar = _def.gvar
		slider_menu = _def.menu
		slider_info_id = variable_struct_exists(_def, "info") ? _def.info : -1
		slider_soundchange_id = variable_struct_exists(_def, "soundchange_id") ? _def.soundchange_id : 1
		slider_label = _def.label

		// Custom range support
		if variable_struct_exists(_def, "slider_min") { slider_min = _def.slider_min }
		if variable_struct_exists(_def, "slider_max") { slider_max = _def.slider_max }
		if variable_struct_exists(_def, "slider_integer") { slider_integer = _def.slider_integer }
		if variable_struct_exists(_def, "slider_beginx_offset") { slider_beginx_offset = _def.slider_beginx_offset }

		// Recalculate position based on the global value
		xcam = camera_get_view_x(view_camera[0])
		beginx = xcam + slider_beginx_offset
		endx = beginx + 146
		var _normalized = (slider_max != slider_min) ? (variable_global_get(slider_gvar) - slider_min) / (slider_max - slider_min) : 0
		x = beginx + (_normalized * 146) - 200
	}
}
