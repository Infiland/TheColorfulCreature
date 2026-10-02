if (!timing_instance_step()) exit;
if (room != r_support) exit;
var _device = gamepad_remap_active_device(true);
var _open = timing_keyboard_pressed(ord("C")) || (_device >= 0 && tcc_gamepad_button_check_pressed(_device, gp_face3));
var _contacts = platform_touch() ? 10 : 1;
for (var _finger = 0; _finger < _contacts; ++_finger) {
    if (timing_device_mouse_pressed(_finger, mb_left)
        && point_in_rectangle(device_mouse_x(_finger), device_mouse_y(_finger), x, y, x + button_width, y + button_height)) _open = true;
}
if (_open) commentary_open();
