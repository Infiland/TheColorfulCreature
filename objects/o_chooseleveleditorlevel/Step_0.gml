if (!timing_instance_step()) exit;
var _device = gamepad_remap_active_device(true);
var _left = timing_keyboard_pressed(vk_left) || (_device >= 0 && tcc_gamepad_button_check_pressed(_device, gp_shoulderl));
var _right = timing_keyboard_pressed(vk_right) || (_device >= 0 && tcc_gamepad_button_check_pressed(_device, gp_shoulderr));
if (_left) { page = max(1, page - 1); selection = (page - 1) * 15; }
if (_right) { page = min(maxpage, page + 1); selection = (page - 1) * 15; }
if (timing_keyboard_pressed(vk_escape) || (_device >= 0 && tcc_gamepad_button_check_pressed(_device, gp_face2))) { instance_destroy(); exit; }
if (len == 0) exit;
if (timing_keyboard_pressed(vk_up) || (_device >= 0 && tcc_gamepad_button_check_pressed(_device, gp_padu))) selection = max(0, selection - 1);
if (timing_keyboard_pressed(vk_down) || (_device >= 0 && tcc_gamepad_button_check_pressed(_device, gp_padd))) selection = min(len - 1, selection + 1);
page = 1 + (selection div 15);
var _open = timing_keyboard_pressed(vk_enter) || (_device >= 0 && tcc_gamepad_button_check_pressed(_device, gp_face1));
var _contacts = platform_touch() ? 10 : 1;
var _xcam = camera_get_view_x(view_camera[0]) + 512;
for (var _finger = 0; _finger < _contacts; ++_finger) {
    if (!timing_device_mouse_released(_finger, mb_left)) continue;
    var _mx = device_mouse_x(_finger), _my = device_mouse_y(_finger);
    var _row = floor((_my - 85) / 40);
    var _index = (page - 1) * 15 + _row;
    if (_mx >= _xcam - 300 && _mx <= _xcam + 300 && _row >= 0 && _row < 15 && _index < len && (_my - 85) mod 40 <= 30) {
        selection = _index; _open = true;
    }
}
if (_open && !level_editor_open(files[selection])) error_text = global.level_last_error;
