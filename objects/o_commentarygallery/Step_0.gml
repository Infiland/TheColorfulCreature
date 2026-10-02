if (!timing_instance_step()) exit;
var _elapsed = timing_tick_seconds();
var _device = gamepad_remap_active_device(true);
var _back = timing_keyboard_pressed(vk_escape) || (_device >= 0 && tcc_gamepad_button_check_pressed(_device, gp_face2));
var _previous = timing_keyboard_pressed(vk_left) || (_device >= 0 && (tcc_gamepad_button_check_pressed(_device, gp_padl) || tcc_gamepad_button_check_pressed(_device, gp_shoulderl)));
var _next = timing_keyboard_pressed(vk_right) || (_device >= 0 && (tcc_gamepad_button_check_pressed(_device, gp_padr) || tcc_gamepad_button_check_pressed(_device, gp_shoulderr)));
var _sources = timing_keyboard_pressed(ord("S")) || (_device >= 0 && tcc_gamepad_button_check_pressed(_device, gp_face3));
var _open_source = show_sources && (timing_keyboard_pressed(vk_enter) || (_device >= 0 && tcc_gamepad_button_check_pressed(_device, gp_face1)));
var _jump = -1;
var _contacts = platform_touch() ? 10 : 1;
for (var _finger = 0; _finger < _contacts; ++_finger) {
    if (!timing_device_mouse_pressed(_finger, mb_left)) continue;
    var _mx = device_mouse_x_to_gui(_finger), _my = device_mouse_y_to_gui(_finger);
    if (point_in_rectangle(_mx, _my, 840, 34, 992, 78)) { _back = true; break; }
    if (!has_access || is_undefined(catalog)) continue;
    if (point_in_rectangle(_mx, _my, 32, 687, 217, 734)) _previous = true;
    if (point_in_rectangle(_mx, _my, 823, 687, 992, 734)) _next = true;
    if (point_in_rectangle(_mx, _my, 625, 687, 803, 734)) _sources = true;
    if (point_in_rectangle(_mx, _my, 32, 108, 992, 136)) _jump = min(array_length(catalog.chapters) - 1, floor((_mx - 32) / (960 / array_length(catalog.chapters))));
    if (show_sources) {
        var _row = floor((_my - 284) / 99);
        if (_mx >= 384 && _mx <= 992 && _row >= 0 && _row < array_length(catalog.chapters[chapter_index].sources)) source_index = _row;
        if (point_in_rectangle(_mx, _my, 384, 603, 992, 649)) _open_source = true;
    }
}
if (_back) {
    if (show_sources) show_sources = false;
    else leave_gallery();
    exit;
}
if (!has_access || is_undefined(catalog)) exit;
access_wait -= _elapsed;
if (access_wait <= 0) {
    access_wait = 2;
    if (!commentary_has_access()) { has_access = false; release_art(); catalog = undefined; position_dirty = false; exit; }
}
if (timing_keyboard_pressed(vk_home)) _jump = 0;
if (timing_keyboard_pressed(vk_end)) _jump = array_length(catalog.chapters) - 1;
if (_jump >= 0) set_chapter(_jump);
else if (_previous && chapter_index > 0) set_chapter(chapter_index - 1);
else if (_next && chapter_index < array_length(catalog.chapters) - 1) set_chapter(chapter_index + 1);
else if (_sources) show_sources = !show_sources;
if (show_sources) {
    if (timing_keyboard_pressed(vk_up) || (_device >= 0 && tcc_gamepad_button_check_pressed(_device, gp_padu))) source_index = max(0, source_index - 1);
    if (timing_keyboard_pressed(vk_down) || (_device >= 0 && tcc_gamepad_button_check_pressed(_device, gp_padd))) source_index = min(array_length(catalog.chapters[chapter_index].sources) - 1, source_index + 1);
    if (_open_source) {
        var _url = catalog.chapters[chapter_index].sources[source_index].url;
        if (commentary_source_url_valid(_url)) url_open(_url);
    }
}
if (position_dirty) {
    save_wait -= _elapsed;
    if (save_wait <= 0) {
        if (commentary_position_write(catalog, chapter_index)) { position_dirty = false; status_text = ""; }
        else { status_text = "Reading position could not be saved. It will be retried."; save_wait = 5; }
    }
}
