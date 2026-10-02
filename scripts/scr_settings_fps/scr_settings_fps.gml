// User-selected rendering cap. Gameplay retains its fixed 60 Hz domain.
function settings_fps_value(_value) {
    if (!is_numeric(_value) || is_nan(_value) || is_infinity(_value)
        || _value < 30 || _value > 1000 || _value != floor(_value)) return 60;
    return _value;
}
function settings_fps_presets() { return [60, 75, 100, 120, 144, 150]; }
function settings_fps_next_preset(_value) {
    var _values = settings_fps_presets();
    for (var _i = 0; _i < array_length(_values); ++_i) {
        if (_value == _values[_i]) return _values[(_i + 1) mod array_length(_values)];
    }
    return 60;
}
function settings_fps_parse(_text) {
    var _invalid = {ok: false, value: 60, error: "Enter a whole number from 30 to 1000."};
    if (!is_string(_text) || string_length(_text) == 0 || string_length(_text) > 4) return _invalid;
    for (var _i = 1; _i <= string_length(_text); ++_i) {
        var _code = ord(string_char_at(_text, _i));
        if (_code < ord("0") || _code > ord("9")) return _invalid;
    }
    var _value = real(_text);
    if (_value < 30 || _value > 1000) return _invalid;
    return {ok: true, value: _value, error: ""};
}
function settings_fps_editor(_value) {
    _value = settings_fps_value(_value);
    return {text: string(_value), original: _value, replace: true, error: ""};
}
function settings_fps_edit(_editor, _text) {
    _editor.text = string_copy((_editor.replace ? "" : _editor.text) + _text, 1, 32);
    _editor.replace = false;
    _editor.error = "";
}
function settings_fps_adjust(_editor, _amount) {
    var _parsed = settings_fps_parse(_editor.text);
    var _value = _parsed.ok ? _parsed.value : _editor.original;
    _editor.text = string(clamp(_value + _amount, 30, 1000));
    _editor.replace = true;
    _editor.error = "";
}
function settings_fps_apply_rate() {
    global.maxfps = TCC_SIM_HZ;
    global.renderfps = settings_fps_value(variable_global_exists("renderfps") ? global.renderfps : 60);
    timing_apply_render_rate();
}
// Narrow demo restore: the demo retains its other legacy settings restrictions.
// A separate helper lets native Check exercise this exact path without faking
// Steam ownership, application identity or external service state.
function settings_fps_read_file(_directory) {
    var _path = _directory + "Settings.sav";
    scr_save_recover(_path);
    if (!file_exists(_path)) return 60;
    ini_open(_path);
    var _value = ini_read_real("Settings", "Max FPS", 60);
    ini_close();
    return settings_fps_value(_value);
}
function settings_fps_commit(_text, _directory = undefined) {
    var _parsed = settings_fps_parse(_text);
    if (!_parsed.ok) return _parsed;
    var _previous = settings_fps_value(variable_global_exists("renderfps") ? global.renderfps : 60);
    global.renderfps = _parsed.value;
    if (!scr_savesettings(_directory)) {
        global.renderfps = _previous;
        return {ok: false, value: _previous, error: "Could not save settings. Please try again."};
    }
    settings_fps_apply_rate();
    return _parsed;
}
function settings_fps_active() { return instance_exists(o_settingsfpsdialog); }
// The close click, controller button and Escape release belong to the modal.
// All settings consumers use this guard, regardless of instance event ordering.
function settings_fps_input_blocked() {
    if (settings_fps_active()) return true;
    if (variable_global_exists("settings_fps_closed_at") && global.settings_fps_closed_at == current_time) return true;
    if (!variable_global_exists("settings_fps_releasing") || !global.settings_fps_releasing) return false;
    if (timing_keyboard_down(vk_anykey) || timing_device_mouse_down(0, mb_left)
        || timing_device_mouse_down(0, mb_right) || gamepad_remap_any_held(gamepad_remap_active_device())) return true;
    global.settings_fps_releasing = false;
    global.settings_fps_closed_at = current_time;
    return true;
}
function settings_fps_close() {
    if (settings_fps_active()) instance_destroy(o_settingsfpsdialog);
}
function settings_fps_consume_back() {
    if (settings_fps_active()) { settings_fps_close(); return true; }
    return settings_fps_input_blocked();
}
function settings_fps_open() {
    if (settings_fps_active()) return;
    gamepad_remap_cancel();
    with (o_settingslider) { settings_slider_commit(); grab = false; slider_adjusting = false; }
    global.soundchange = 0;
    timing_create_depth(0, 0, -10000000020, o_settingsfpsdialog);
}
function settings_fps_layout() {
    var _gw = display_get_gui_width(), _gh = display_get_gui_height();
    var _scale = min(1, min(_gw / 704, _gh / 720));
    return {x: (_gw - 640 * _scale) / 2, y: (_gh - 664 * _scale) / 2, scale: _scale};
}
function settings_fps_widgets() {
    var _buttons = [];
    var _presets = settings_fps_presets();
    for (var _p = 0; _p < array_length(_presets); ++_p) {
        array_push(_buttons, {x: 24 + 100 * _p, y: 174, w: 92, h: 42, text: string(_presets[_p]), action: "value", value: _presets[_p]});
    }
    var _keys = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "Clear", "0", "Delete"];
    for (var _k = 0; _k < 12; ++_k) {
        array_push(_buttons, {x: 24 + 132 * (_k mod 3), y: 236 + 58 * floor(_k / 3), w: 124, h: 50,
            text: _keys[_k], action: _k == 9 ? "clear" : (_k == 11 ? "delete" : "digit"), value: _keys[_k]});
    }
    var _steps = [-1, 1, -10, 10, -100, 100];
    for (var _s = 0; _s < 6; ++_s) {
        array_push(_buttons, {x: 432 + 96 * (_s mod 2), y: 236 + 58 * floor(_s / 2), w: 88, h: 50,
            text: (_steps[_s] > 0 ? "+" : "") + string(_steps[_s]), action: "adjust", value: _steps[_s]});
    }
    array_push(_buttons, {x: 432, y: 410, w: 184, h: 50, text: "Reset to 60", action: "value", value: 60});
    array_push(_buttons, {x: 24, y: 568, w: 284, h: 52, text: "Apply", action: "apply", value: 0});
    array_push(_buttons, {x: 332, y: 568, w: 284, h: 52, text: "Cancel", action: "cancel", value: 0});
    return _buttons;
}
function settings_fps_dialog_action(_action, _value = 0) {
    switch (_action) {
        case "digit": settings_fps_edit(fps_editor, string(_value)); break;
        case "clear": fps_editor.text = ""; fps_editor.replace = false; fps_editor.error = ""; break;
        case "delete":
            fps_editor.text = fps_editor.replace || fps_editor.text == "" ? "" : string_delete(fps_editor.text, string_length(fps_editor.text), 1);
            fps_editor.replace = false; fps_editor.error = ""; break;
        case "value": fps_editor.text = string(_value); fps_editor.replace = true; fps_editor.error = ""; break;
        case "adjust": settings_fps_adjust(fps_editor, _value); break;
        case "apply":
            var _result = settings_fps_commit(fps_editor.text, fps_save_directory);
            if (_result.ok) settings_fps_close(); else fps_editor.error = _result.error;
            break;
        case "cancel": settings_fps_close(); break;
    }
}
function settings_fps_dialog_step() {
    var _device = gamepad_remap_active_device(true);
    // The opener's click/A must release before it can apply the new value.
    if (!fps_armed) {
        if (!timing_keyboard_down(vk_anykey) && !timing_device_mouse_down(0, mb_left) && !gamepad_remap_any_held(_device)) fps_armed = true;
        keyboard_string = "";
        return;
    }
    if (timing_keyboard_pressed(vk_escape) || timing_mouse_pressed(mb_right)
        || (_device >= 0 && (tcc_gamepad_button_check_pressed(_device, gp_face2) || tcc_gamepad_button_check_pressed(_device, gp_start)))) {
        settings_fps_close(); return;
    }
    if (timing_keyboard_down(vk_control) && timing_keyboard_pressed(ord("A"))) { fps_editor.replace = true; keyboard_string = ""; }
    if (timing_keyboard_pressed(vk_backspace) || timing_keyboard_pressed(vk_delete)) settings_fps_dialog_action("delete");
    else if (keyboard_string != "" && !timing_keyboard_pressed(vk_enter)) settings_fps_edit(fps_editor, keyboard_string);
    keyboard_string = "";
    if (timing_keyboard_pressed(vk_home) || (_device >= 0 && tcc_gamepad_button_check_pressed(_device, gp_face3))) settings_fps_dialog_action("value", 60);
    var _adjust = 0;
    if (timing_keyboard_down(vk_left) || (_device >= 0 && tcc_gamepad_button_check(_device, gp_padl))) _adjust -= 1;
    if (timing_keyboard_down(vk_right) || (_device >= 0 && tcc_gamepad_button_check(_device, gp_padr))) _adjust += 1;
    if (_device >= 0) {
        if (tcc_gamepad_button_check(_device, gp_shoulderl)) _adjust -= 10;
        if (tcc_gamepad_button_check(_device, gp_shoulderr)) _adjust += 10;
    }
    if (_adjust != 0) {
        fps_repeat -= 60 / TCC_SIM_HZ;
        if (_adjust != fps_last_adjust || fps_repeat <= 0) {
            settings_fps_dialog_action("adjust", _adjust);
            fps_repeat = _adjust != fps_last_adjust ? 20 : 4;
        }
    }
    fps_last_adjust = _adjust;
    if (timing_keyboard_pressed(vk_enter) || (_device >= 0 && tcc_gamepad_button_check_pressed(_device, gp_face1))) {
        settings_fps_dialog_action("apply"); return;
    }
    if (timing_device_mouse_pressed(0, mb_left)) {
        var _layout = settings_fps_layout();
        var _mx = (device_mouse_x_to_gui(0) - _layout.x) / _layout.scale;
        var _my = (device_mouse_y_to_gui(0) - _layout.y) / _layout.scale;
        if (point_in_rectangle(_mx, _my, 24, 104, 616, 158)) fps_editor.replace = true;
        var _buttons = settings_fps_widgets();
        for (var _i = 0; _i < array_length(_buttons); ++_i) {
            var _b = _buttons[_i];
            if (point_in_rectangle(_mx, _my, _b.x, _b.y, _b.x + _b.w, _b.y + _b.h)) {
                settings_fps_dialog_action(_b.action, _b.value); return;
            }
        }
    }
}
function settings_fps_dialog_draw() {
    var _l = settings_fps_layout(), _s = _l.scale;
    draw_set_alpha(0.85); draw_set_color(c_black);
    draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
    draw_set_alpha(1); draw_set_color(make_color_rgb(12, 12, 12));
    draw_rectangle(_l.x, _l.y, _l.x + 640 * _s, _l.y + 664 * _s, false);
    draw_set_color(c_white); draw_rectangle(_l.x, _l.y, _l.x + 640 * _s, _l.y + 664 * _s, true);
    draw_set_font(fnt_mainmenu); draw_set_halign(fa_center); draw_set_valign(fa_middle);
    draw_text_transformed(_l.x + 320 * _s, _l.y + 35 * _s, settings_text("Custom FPS Cap"), 0.55 * _s, 0.55 * _s, 0);
    draw_text_transformed(_l.x + 320 * _s, _l.y + 76 * _s, settings_text("Render cap: 30 to 1000 FPS. Default: 60."), 0.25 * _s, 0.25 * _s, 0);
    draw_set_color(fps_editor.replace ? make_color_rgb(45, 45, 65) : make_color_rgb(20, 20, 20));
    draw_rectangle(_l.x + 24 * _s, _l.y + 104 * _s, _l.x + 616 * _s, _l.y + 158 * _s, false);
    draw_set_color(c_white); draw_rectangle(_l.x + 24 * _s, _l.y + 104 * _s, _l.x + 616 * _s, _l.y + 158 * _s, true);
    var _text = fps_editor.text == "" ? "_" : fps_editor.text;
    var _size = min(0.55, 550 / max(1, string_width(_text)));
    draw_text_transformed(_l.x + 320 * _s, _l.y + 131 * _s, _text, _size * _s, _size * _s, 0);
    var _buttons = settings_fps_widgets();
    var _mx = (device_mouse_x_to_gui(0) - _l.x) / _s, _my = (device_mouse_y_to_gui(0) - _l.y) / _s;
    for (var _i = 0; _i < array_length(_buttons); ++_i) {
        var _b = _buttons[_i];
        var _hover = point_in_rectangle(_mx, _my, _b.x, _b.y, _b.x + _b.w, _b.y + _b.h);
        draw_set_color(_hover ? make_color_rgb(55, 55, 55) : make_color_rgb(20, 20, 20));
        draw_rectangle(_l.x + _b.x * _s, _l.y + _b.y * _s, _l.x + (_b.x + _b.w) * _s, _l.y + (_b.y + _b.h) * _s, false);
        draw_set_color(c_white);
        draw_rectangle(_l.x + _b.x * _s, _l.y + _b.y * _s, _l.x + (_b.x + _b.w) * _s, _l.y + (_b.y + _b.h) * _s, true);
        var _label = settings_text(_b.text);
        var _font_scale = min(0.4, (_b.w - 12) / max(1, string_width(_label)));
        draw_text_transformed(_l.x + (_b.x + _b.w / 2) * _s, _l.y + (_b.y + _b.h / 2) * _s, _label, _font_scale * _s, _font_scale * _s, 0);
    }
    draw_set_color(c_white);
    draw_text_transformed(_l.x + 320 * _s, _l.y + 486 * _s, settings_text("Type or tap digits. Enter: apply. Esc: cancel."), 0.23 * _s, 0.23 * _s, 0);
    draw_text_transformed(_l.x + 320 * _s, _l.y + 514 * _s, settings_text("D-pad: +/-1   LB/RB: +/-10   X: 60   A: apply   B: cancel"), 0.22 * _s, 0.22 * _s, 0);
    draw_set_color(make_color_rgb(255, 150, 150));
    draw_text_transformed(_l.x + 320 * _s, _l.y + 545 * _s, settings_text(fps_editor.error), 0.22 * _s, 0.22 * _s, 0);
    draw_set_color(c_white); draw_set_halign(fa_left); draw_set_valign(fa_top); draw_set_alpha(1);
}
function settings_fps_selfcheck() {
    var _valid = [30, 60, 75, 90, 144, 237, 360, 1000];
    for (var _i = 0; _i < array_length(_valid); ++_i) {
        scr_port_assert(settings_fps_value(_valid[_i]) == _valid[_i] && settings_fps_parse(string(_valid[_i])).ok, "whole FPS values preserve custom choices and endpoints");
    }
    var _invalid = ["", "29", "1001", "60.5", "60.0", "1e2", "+60", "-60", "60fps", "NaN", "Infinity", " 60", "6000000000000000000"];
    for (var _j = 0; _j < array_length(_invalid); ++_j) scr_port_assert(!settings_fps_parse(_invalid[_j]).ok, "malformed FPS text cannot be applied: " + _invalid[_j]);
    scr_port_assert(settings_fps_value(-5) == 60 && settings_fps_value(1001) == 60 && settings_fps_value(60.5) == 60 && settings_fps_value("90") == 60, "invalid saved FPS values use default 60");
    var _editor = settings_fps_editor(60);
    settings_fps_edit(_editor, "2"); settings_fps_edit(_editor, "37");
    scr_port_assert(_editor.text == "237" && _editor.original == 60, "editing replaces selected text without changing original choice");
    settings_fps_adjust(_editor, 1000);
    scr_port_assert(_editor.text == "1000", "controller adjustment clamps high endpoint");
    settings_fps_adjust(_editor, -1000);
    scr_port_assert(_editor.text == "30", "controller adjustment clamps low endpoint");
    scr_port_assert(settings_fps_next_preset(150) == 60 && settings_fps_next_preset(237) == 60 && settings_fps_next_preset(60) == 75, "preset cycle remains predictable after custom FPS");
    show_debug_message("TCC_CUSTOM_FPS_VALIDATION_PASS");
}
function settings_fps_runtime_selfcheck(_directory) {
    if (!TCC_SELF_CHECK) return;
    var _previous = global.renderfps;
    var _applied = settings_fps_commit("237", _directory);
    scr_port_assert(_applied.ok && global.renderfps == 237 && global.maxfps == TCC_SIM_HZ && game_get_speed(gamespeed_fps) == max(TCC_SIM_HZ, 237), "custom render cap applies without changing gameplay rate");
    global.renderfps = 60;
    scr_loadsettings(_directory);
    settings_fps_apply_rate(); // Same restoration path as title Create after relaunch.
    scr_port_assert(global.renderfps == 237 && global.maxfps == TCC_SIM_HZ && game_get_speed(gamespeed_fps) == max(TCC_SIM_HZ, 237), "custom render cap survives save, load and title restoration");
    var _rejected = settings_fps_commit("237.5", _directory);
    scr_loadsettings(_directory);
    scr_port_assert(!_rejected.ok && global.renderfps == 237 && global.maxfps == TCC_SIM_HZ, "invalid dialog text leaves the saved render cap unchanged");
    var _was_releasing = variable_global_exists("settings_fps_releasing") ? global.settings_fps_releasing : false;
    var _closed_at = variable_global_exists("settings_fps_closed_at") ? global.settings_fps_closed_at : -1;
    var _keyboard = keyboard_string;
    var _dialog = timing_create_depth(0, 0, -10000000020, o_settingsfpsdialog);
    scr_port_assert(settings_fps_active() && settings_fps_input_blocked(), "FPS modal locks underlying settings input");
    with (_dialog) {
        fps_save_directory = _directory;
        settings_fps_dialog_action("value", 360);
    }
    scr_port_assert(global.renderfps == 237 && global.maxfps == TCC_SIM_HZ && _dialog.fps_editor.text == "360", "dialog edits remain pending until Apply");
    with (_dialog) {
        fps_editor.text = "1001";
        settings_fps_dialog_action("apply");
    }
    scr_port_assert(instance_exists(_dialog) && global.renderfps == 237 && global.maxfps == TCC_SIM_HZ && _dialog.fps_editor.error != "", "invalid Apply keeps dialog open and saved render cap intact");
    with (_dialog) { settings_fps_dialog_action("cancel"); }
    scr_port_assert(!settings_fps_active() && global.renderfps == 237 && global.maxfps == TCC_SIM_HZ && global.settings_fps_releasing, "Cancel closes dialog without changes and consumes release input");
    _dialog = timing_create_depth(0, 0, -10000000020, o_settingsfpsdialog);
    with (_dialog) {
        fps_save_directory = _directory;
        settings_fps_dialog_action("value", 360);
        settings_fps_dialog_action("apply");
    }
    scr_loadsettings(_directory);
    scr_port_assert(!settings_fps_active() && global.renderfps == 360 && global.maxfps == TCC_SIM_HZ && game_get_speed(gamespeed_fps) == max(TCC_SIM_HZ, 360), "dialog Apply saves the render cap through the isolated native INI transaction");
    scr_port_assert(settings_fps_read_file(_directory) == 360, "demo FPS-only restoration reads the existing custom preference");
    scr_port_assert(settings_fps_read_file(_directory + "NoSavedPreference/") == 60, "demo without a saved preference retains default 60");
    global.settings_fps_releasing = _was_releasing;
    global.settings_fps_closed_at = _closed_at;
    keyboard_string = _keyboard;
    var _bad = [-10, 29, 1001, 60.5];
    for (var _i = 0; _i < array_length(_bad); ++_i) {
        ini_open(_directory + "Settings.sav"); ini_write_real("Settings", "Max FPS", _bad[_i]); ini_close();
        scr_loadsettings(_directory);
        scr_port_assert(global.renderfps == 60 && global.maxfps == TCC_SIM_HZ, "invalid persisted render cap falls back safely");
        scr_port_assert(settings_fps_read_file(_directory) == 60, "demo FPS-only restoration also rejects invalid persisted values");
    }
    var _caps = [30, 31, 60, 75, 100, 120, 144, 150, 1000];
    for (var _c = 0; _c < array_length(_caps); ++_c) {
        var _cap = _caps[_c];
        var _cap_result = settings_fps_commit(string(_cap), _directory);
        ini_open(_directory + "Settings.sav");
        var _stored_cap = ini_read_real("Settings", "Max FPS", -1);
        ini_close();
        scr_port_assert(_cap_result.ok && _stored_cap == _cap && global.renderfps == _cap && global.maxfps == TCC_SIM_HZ
            && game_get_speed(gamespeed_fps) == max(TCC_SIM_HZ, _cap), "legacy Max FPS key preserves render cap with fixed gameplay rate: " + string(_cap));
        global.renderfps = 60;
        scr_loadsettings(_directory);
        settings_fps_apply_rate();
        scr_port_assert(global.renderfps == _cap && global.maxfps == TCC_SIM_HZ
            && game_get_speed(gamespeed_fps) == max(TCC_SIM_HZ, _cap), "saved render cap restores the separate timing domains: " + string(_cap));
    }
    global.renderfps = _previous;
    settings_fps_apply_rate();
    show_debug_message("TCC_DEMO_FPS_RESTORE_PASS");
    show_debug_message("TCC_CUSTOM_FPS_PERSISTENCE_PASS");
}
