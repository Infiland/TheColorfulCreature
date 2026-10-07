// Settings callbacks and shared spawning logic.

/// @function scr_spawn_settings_buttons()
/// @description Spawns all data-driven settings buttons, sliders, controls and language buttons
function scr_spawn_settings_buttons() {
	var _defs = scr_settings_definitions()
	var _cx = camera_get_view_x(view_camera[0])
	var _cy = camera_get_view_y(view_camera[0])
	global.soundchange = 0
    if (platform_mobile()) {
        global.mobile_settings_menu = -1;
        global.mobile_settings_page = 0;
        global.mobile_settings_counts = array_create(8, 0);
        global.mobile_settings_counts[6] = 6;
        // Mobile settings omit controls which have no effect on this port.
        var _mobile_defs = [];
        for (var _n = 0; _n < array_length(_defs); ++_n) {
            var _entry = _defs[_n];
            var _key = variable_struct_exists(_entry, "gvar") ? _entry.gvar : "";
            if (_key == "fullscreen" || _key == "objcountersettings" || _key == "autothumbnailsettings"
                || _key == "antialiasingsettings" || _key == "vsyncsettings" || _key == "netmaxplayers") continue;
            if (_key == "controllervibrationsettings") _entry.menu = 6;
            array_push(_mobile_defs, _entry);
        }
        _defs = _mobile_defs;
        array_push(_defs, {type:STYPE.ACTION, menu:3, col:0, row:0, label:"DEFAULT_CONTROLS", callback:function() { platform_touch_defaults(); scr_saveandroid(); }});
        array_push(_defs, {type:STYPE.CATEGORY, menu:3, col:0, row:0, label:"Adjust touch positions", target_menu:7, callback:function() { settings_mobile_controls_create(); if (instance_exists(o_animatedtext)) o_animatedtext.text = settings_text("Adjust touch positions"); }});
        array_push(_defs, {type:STYPE.CATEGORY, menu:3, col:0, row:0, label:"Controller", target_menu:6, callback:function() { hideandroidbuttons(); }});
        array_push(_defs, {type:STYPE.ACTION, menu:6, col:0, row:0, label:"DEFAULT_CONTROLS", callback:function() { gamepad_remap_defaults(); scr_savesettings(); }});
    }

	for (var i = 0; i < array_length(_defs); i++) {
		var _d = _defs[i]
        if (!platform_steam() && variable_struct_exists(_d, "dlc_gate")) continue;
        if (variable_struct_exists(_d, "mobile_only") && !platform_mobile()) continue;
        if (variable_struct_exists(_d, "mobile_privacy") && (!platform_admob() || !tcc_privacy_options_required())) continue;

		if _d.type = STYPE.SLIDER {
			var _inst = instance_create(_cx, _cy + 160 + (_d.row * 64), o_settingslider)
			slider_apply_from_def(_inst, _d)
            if (platform_mobile()) _inst.mobile_settings_slot = settings_mobile_next_slot(_d.menu);
		} else {
			var _inst = instance_create(_cx - 256, _cy + 160 + (_d.row * 64), o_settingbutton)
			settings_apply_from_def(_inst, _d)
            if (platform_mobile()) _inst.mobile_settings_slot = settings_mobile_next_slot(_d.menu);
		}
	}

	// Controls (for-loop pattern)
	for (var i = 0; i < 6; i++) {
		var _ctrl = instance_create(_cx - 128, _cy + 160 + 80 * i, o_controlsbuttonsettings)
		with _ctrl {
			controls = i
            if (platform_mobile()) mobile_settings_slot = i;
		}
	}

	if (platform_mobile()) {
        for (var _language = 0; _language <= 17; ++_language) {
            var _lang_button = instance_create(_cx - 2000, _cy, o_settingbutton);
            settings_apply_from_def(_lang_button, {type:STYPE.ACTION, menu:5, col:0, row:0, label:timing_ui_language_text(_language)});
            _lang_button.mobile_settings_slot = settings_mobile_next_slot(5);
            _lang_button.mobile_language = _language;
        }
        for (var _direction = -1; _direction <= 1; _direction += 2) {
            var _nav = instance_create(_cx - 2000, _cy, o_settingbutton);
            _nav.mobile_page_direction = _direction;
        }
        return;
    }

    var _dkb
	if !platform_mobile() {
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
		x = beginx + (clamp(_normalized, 0, 1) * 146) - 200
	}
}

// A gesture changes the value immediately and writes once on release/exit.
function settings_slider_commit() {
    if (slider_dirty) {
        slider_dirty = false;
        scr_savesettings();
    }
}

// Touch settings use the existing setting callbacks and save paths, with six
// spacious rows per page instead of the desktop's eight-row/three-column grid.
function settings_mobile_next_slot(_menu) {
    var _slot = global.mobile_settings_counts[_menu];
    global.mobile_settings_counts[_menu] += 1;
    return _slot;
}

function settings_mobile_page_count() {
    return max(1, ceil(global.mobile_settings_counts[global.choosesettings] / 6));
}

function settings_mobile_layout(_menu, _slot) {
    if (global.mobile_settings_menu != global.choosesettings) {
        global.mobile_settings_menu = global.choosesettings;
        global.mobile_settings_page = 0;
        global.infosettings = 0;
    }
    var _active = global.choosesettings == _menu && floor(_slot / 6) == global.mobile_settings_page;
    visible = _active;
    var _cx = camera_get_view_x(view_camera[0]), _cy = camera_get_view_y(view_camera[0]);
    x = _cx + (_active ? 32 + (_slot mod 2) * 488 : -2000);
    y = _cy + 152 + floor((_slot mod 6) / 2) * 120;
    mobile_card_width = 464; mobile_card_height = 108;
    image_xscale = 464 / sprite_get_width(sprite_index); image_yscale = 108 / sprite_get_height(sprite_index);
    if (!_active) mouseon = false;
    return _active;
}

function settings_mobile_controls_create() {
    if (!instance_exists(o_buttonleftandroid)) instance_create(0, 0, o_buttonleftandroid);
    if (!instance_exists(o_buttonrightandroid)) instance_create(0, 0, o_buttonrightandroid);
    if (!instance_exists(o_buttonjumpandroid)) instance_create(0, 0, o_buttonjumpandroid);
    if (!instance_exists(o_buttoninteractandroid)) instance_create(0, 0, o_buttoninteractandroid);
    if (!instance_exists(o_buttonrestartandroid)) instance_create(0, 0, o_buttonrestartandroid);
    if (!instance_exists(o_buttonskipandroid)) instance_create(0, 0, o_buttonskipandroid);
}

function settings_mobile_back() {
    if (!platform_mobile() || (global.choosesettings != 6 && global.choosesettings != 7)
        || (room != r_settings && !instance_exists(o_settingspausemenu))) return false;
    gamepad_remap_cancel();
    global.choosesettings = 3;
    hideandroidbuttons();
    scr_saveandroid();
    if (instance_exists(o_animatedtext)) o_animatedtext.text = loc("CHANGE_CONTROLS");
    scr_savesettings();
    return true;
}

function settings_mobile_draw_card(_label, _value) {
    var _w = mobile_card_width, _h = mobile_card_height;
    draw_set_alpha(1);
    draw_set_color(make_color_rgb(12, 12, 12));
    draw_rectangle(x, y, x + _w, y + _h, false);
    draw_set_color(image_alpha < 1 ? c_gray : c_white);
    draw_rectangle(x, y, x + _w, y + _h, true);
    draw_set_font(fnt_mainmenu);
    draw_set_halign(fa_center); draw_set_valign(fa_middle);
    var _has_value = _value != "";
    var _scale = min(0.78, (_w - 28) / max(1, string_width(_label)));
    draw_text_transformed(x + _w / 2, y + (_has_value ? 31 : _h / 2), _label, _scale, _scale, 0);
    if (_has_value) {
        draw_set_color(image_alpha < 1 ? c_gray : c_aqua);
        var _value_scale = min(0.64, (_w - 28) / max(1, string_width(_value)));
        draw_text_transformed(x + _w / 2, y + 73, _value, _value_scale, _value_scale, 0);
    }
    draw_set_halign(fa_left); draw_set_valign(fa_top); draw_set_color(c_white);
}

function settings_mobile_draw_setting() {
    var _label = settings_text(setting_label), _value = "";
    if (mobile_page_direction != 0) {
        _label = mobile_page_direction < 0 ? "<" : ">";
        _value = string(global.mobile_settings_page + 1) + " / " + string(settings_mobile_page_count());
    } else if (mobile_language >= 0) {
        if (global.language == mobile_language) _value = settings_text("Selected");
    } else if (setting_gvar != "") {
        var _current = variable_global_get(setting_gvar);
        if (setting_type == STYPE.TOGGLE) _value = settings_text(_current >= 1 ? "On" : "Off");
        else if (setting_gvar == "renderfps") _value = string(_current) + " FPS";
        else if (is_array(setting_options) && _current >= 0 && _current < array_length(setting_options)) _value = settings_text(setting_options[_current]);
        else _value = string(_current);
    } else if (setting_type == STYPE.CATEGORY) _value = ">";
    settings_mobile_draw_card(_label, _value);
}
