/// @description Handle page navigation
var _changed = false;

// Keyboard navigation
if (keyboard_check_pressed(vk_left)) {
	if (current_page > 0) {
		current_page--;
		_changed = true;
	}
}
if (keyboard_check_pressed(vk_right)) {
	if (current_page < total_pages - 1) {
		current_page++;
		_changed = true;
	}
}

// Gamepad shoulder buttons
if (gamepad_button_check_pressed(0, gp_shoulderl)) {
	if (current_page > 0) {
		current_page--;
		_changed = true;
	}
}
if (gamepad_button_check_pressed(0, gp_shoulderr)) {
	if (current_page < total_pages - 1) {
		current_page++;
		_changed = true;
	}
}

// Mouse click on page arrows (drawn at y=745, left arrow at x=80, right at x=944)
if (mouse_check_button_pressed(mb_left)) {
	if (current_page > 0 && point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), 40, 720, 120, 760)) {
		current_page--;
		_changed = true;
	}
	if (current_page < total_pages - 1 && point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), 904, 720, 984, 760)) {
		current_page++;
		_changed = true;
	}
}

if (_changed) {
	global.levelselect_page = current_page;
	spawn_page_buttons();
}
