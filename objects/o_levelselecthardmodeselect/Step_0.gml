if (!timing_instance_step()) exit;
if (room != r_levelselectmenu) exit;
if (!levelselect_hardmode_available()) { global.hardmode = 0; exit; }
var _device = gamepad_remap_active_device(true);
var _toggle = timing_keyboard_pressed(ord("H")) || (_device >= 0 && tcc_gamepad_button_check_pressed(_device, gp_face4));
var _contacts = platform_touch() ? 10 : 1;
for (var _i = 0; _i < _contacts; ++_i) {
    if (timing_device_mouse_pressed(_i, mb_left)
        && point_in_rectangle(device_mouse_x_to_gui(_i), device_mouse_y_to_gui(_i), 257, 144, 800, 192)) _toggle = true;
}
if (_toggle) global.hardmode = global.hardmode == 0 ? 1 : 0;
