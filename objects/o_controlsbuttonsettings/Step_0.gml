if (!timing_instance_step()) exit;
if (settings_fps_input_blocked()) exit;
var _device = gamepad_remap_active_device(true);
var _visible;
if (platform_mobile()) {
    _visible = settings_mobile_layout(6, mobile_settings_slot);
} else {
    visible = !platform_touch() || _device >= 0;
    _visible = global.choosesettings == 3 && visible;
    x = lerp(x, camera_get_view_x(view_camera[0]) + (_visible ? 32 : -256), 0.2 * (60 / global.maxfps));
}
var _names = settings_keyboard_names();
controlschoose = variable_global_get(_names[controls]);
ischanging = _visible && editcontrols == controls;
if (!_visible) { if (editcontrols == controls) gamepad_remap_cancel(); exit; }

if (!ischanging) {
    if (mouseon && _device >= 0 && tcc_gamepad_button_check_pressed(_device, gp_face1)) event_perform(ev_mouse, ev_left_press);
    exit;
}
if (timing_keyboard_pressed(vk_escape) || timing_mouse_pressed(mb_right)
    || (capture_device >= 0 && (!tcc_gamepad_is_connected(capture_device)
        || capture_device_generation != timing_pad_generation(capture_device)))) {
    gamepad_remap_cancel(); ischanging = false; exit;
}
// A newly connected controller becomes available after its held buttons release.
if (capture_device < 0 && _device >= 0) {
    capture_device = _device;
    capture_device_generation = timing_pad_generation(capture_device);
    global.gp_remap_device = _device;
    capture_armed = false;
}
// The click/A button which opens listening must be released before capture.
if (!capture_armed) {
    if (!timing_mouse_down(mb_left) && !gamepad_remap_any_held(capture_device) && !timing_keyboard_down(vk_anykey)) capture_armed = true;
    exit;
}
var _changed = false;
var _pressed = gamepad_remap_listen(capture_device);
if (capture_device >= 0 && _pressed != -1) {
    _changed = gamepad_remap_set(controls, _pressed);
} else if (timing_keyboard_pressed(vk_anykey)) {
    // Keyboard remains editable with a controller connected: press either input.
    var _key = settings_keyboard_capture(keyboard_lastkey, keyboard_string);
    if (_key != "") {
        var _valid_key = settings_keyboard_value(_key, "");
        if (_valid_key != "") {
            variable_global_set(_names[controls], _valid_key);
            _changed = true;
        }
    }
    keyboard_string = "";
}
if (_changed) {
    gamepad_remap_cancel();
    ischanging = false;
    if (instance_exists(o_settingspausemenu)) { global.isreversed = true; scr_saveachievements(); }
    scr_savesettings();
}
