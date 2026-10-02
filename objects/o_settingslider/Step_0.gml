if (!timing_instance_step()) exit;
if (settings_fps_input_blocked()) { grab = false; slider_adjusting = false; exit; }
beginx = camera_get_view_x(view_camera[0]) + slider_beginx_offset;
endx = beginx + 146;
if (global.choosesettings != slider_menu) {
    settings_slider_commit();
    grab = false;
    slider_adjusting = false;
    if (global.soundchange == slider_soundchange_id) global.soundchange = 0;
    x = lerp(x, camera_get_view_x(view_camera[0]) - 256, 0.2 * (60 / global.maxfps));
    exit;
}
var _device = gamepad_remap_active_device(true);
var _hover = point_in_rectangle(mouse_x, mouse_y, beginx - 8, y - 4, endx + 8, y + 20);
if (_hover) {
    global.infosettings = slider_info_id;
    if (timing_device_mouse_pressed(0, mb_left)) {
        grab = true;
        global.soundchange = slider_soundchange_id;
    }
    if (_device >= 0 && tcc_gamepad_button_check_pressed(_device, gp_face1)) global.soundchange = slider_soundchange_id;
} else if (!grab && global.infosettings == slider_info_id) global.infosettings = 0;
var _old = variable_global_get(slider_gvar);
var _value = _old;
if (grab) {
    _value = slider_min + clamp((mouse_x - beginx) / 146, 0, 1) * (slider_max - slider_min);
}
var _left = timing_keyboard_down(vk_left) || timing_keyboard_down(ord("A")) || (_device >= 0 && tcc_gamepad_button_check(_device, gp_padl));
var _right = timing_keyboard_down(vk_right) || timing_keyboard_down(ord("D")) || (_device >= 0 && tcc_gamepad_button_check(_device, gp_padr));
var _adjust = !grab && global.soundchange == slider_soundchange_id && (_left != _right);
if (_adjust) {
    slider_repeat -= 60 / global.maxfps;
    if (!slider_adjusting || slider_repeat <= 0) {
        var _step = slider_integer ? max(1, ceil((slider_max - slider_min) / 100)) : 0.01;
        _value += (_right ? 1 : -1) * _step;
        slider_repeat = slider_adjusting ? 4 : 20;
    }
}
_value = clamp(_value, slider_min, slider_max);
if (slider_integer) _value = round(_value);
if (_value != _old) {
    variable_global_set(slider_gvar, _value);
    slider_dirty = true;
    if (slider_gvar == "musicvolume") audio_sound_gain(m_mainmenu, global.musicvolume, 1);
    if (slider_gvar == "mastervolume") platform_master_gain(global.mastervolume);
}
if ((grab && !timing_device_mouse_down(0, mb_left)) || (slider_adjusting && !_adjust)) {
    grab = false;
    settings_slider_commit();
}
slider_adjusting = _adjust;
x = beginx + clamp((_value - slider_min) / max(0.0001, slider_max - slider_min), 0, 1) * 146;
