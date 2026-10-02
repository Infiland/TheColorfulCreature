if (!timing_instance_step()) exit;
if (total_pages < 1) exit;
var _device = gamepad_remap_active_device(true);
var _page_delta = 0;
if (timing_keyboard_pressed(vk_pageup) || timing_keyboard_pressed(ord("Q")) || (_device >= 0 && tcc_gamepad_button_check_pressed(_device, gp_shoulderl))) _page_delta--;
if (timing_keyboard_pressed(vk_pagedown) || timing_keyboard_pressed(ord("E")) || (_device >= 0 && tcc_gamepad_button_check_pressed(_device, gp_shoulderr))) _page_delta++;
var _contacts = platform_touch() ? 10 : 1;
var _launch = false;
for (var _finger = 0; _finger < _contacts; ++_finger) {
    if (!timing_device_mouse_pressed(_finger, mb_left)) continue;
    var _mx = device_mouse_x_to_gui(_finger), _my = device_mouse_y_to_gui(_finger);
    if (point_in_rectangle(_mx, _my, 40, 720, 120, 760)) _page_delta--;
    if (point_in_rectangle(_mx, _my, 904, 720, 984, 760)) _page_delta++;
    if (platform_touch()) {
        var _col = floor((_mx - 37.5) / 96), _row = floor((_my - 250) / 101);
        var _index = _row * 10 + _col;
        if (_col >= 0 && _col < 10 && _row >= 0 && _row < 4 && _index < array_length(pages[current_page].levels)
            && (_mx - 37.5) mod 96 <= 85 && (_my - 250) mod 101 <= 85) {
            selected_level = _index; keyboard_focus = true; _launch = true;
        }
    }
}
if (_page_delta != 0) {
    current_page = clamp(current_page + sign(_page_delta), 0, total_pages - 1);
    global.levelselect_page = current_page;
    spawn_page_buttons();
}
var _levels = pages[current_page].levels;
var _move = 0;
if (timing_keyboard_pressed(vk_left) || (_device >= 0 && tcc_gamepad_button_check_pressed(_device, gp_padl))) _move--;
if (timing_keyboard_pressed(vk_right) || (_device >= 0 && tcc_gamepad_button_check_pressed(_device, gp_padr))) _move++;
if (timing_keyboard_pressed(vk_up) || (_device >= 0 && tcc_gamepad_button_check_pressed(_device, gp_padu))) _move -= 10;
if (timing_keyboard_pressed(vk_down) || (_device >= 0 && tcc_gamepad_button_check_pressed(_device, gp_padd))) _move += 10;
if (_move != 0) { keyboard_focus = true; selected_level = clamp(selected_level + _move, 0, max(0, array_length(_levels) - 1)); }
if (timing_keyboard_pressed(vk_enter) || (_device >= 0 && tcc_gamepad_button_check_pressed(_device, gp_face1))) { keyboard_focus = true; _launch = true; }
if (_launch && array_length(_levels) > 0) levelselect_start(_levels[selected_level]);
// The shared Back object handles keyboard and controller 0; follow another
// connected controller here without dispatching the same back action twice.
if (_device > 0 && tcc_gamepad_button_check_pressed(_device, gp_face2)) scr_back();
