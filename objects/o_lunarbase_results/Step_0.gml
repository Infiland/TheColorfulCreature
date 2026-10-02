if (!timing_instance_step()) exit;
if (result_input_delay > 0) {
    result_input_delay -= 60 / global.maxfps;
    exit;
}
if (timing_keyboard_pressed(vk_escape) || gamepad_ui_pressed(gp_face2)) {
    scr_lunarbase_return();
    exit;
}
if (timing_keyboard_pressed(vk_left) || timing_keyboard_pressed(vk_right)
    || timing_keyboard_pressed(vk_tab) || gamepad_ui_pressed(gp_padl)
    || gamepad_ui_pressed(gp_padr)) {
    result_focus = 1 - result_focus;
}
var _mx = device_mouse_x_to_gui(0), _my = device_mouse_y_to_gui(0);
result_hover = scr_lunarbase_action_at(_mx, _my);
var _action = -1;
if (timing_device_mouse_pressed(0, mb_left)) _action = result_hover;
if (timing_keyboard_pressed(vk_enter) || timing_keyboard_pressed(vk_space)
    || gamepad_ui_pressed(gp_face1)) _action = result_focus;
if (_action == 0) {
    restartchallenge();
} else if (_action == 1) {
    scr_lunarbase_return();
}
