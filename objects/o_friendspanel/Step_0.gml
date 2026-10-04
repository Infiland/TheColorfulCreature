if (!timing_instance_step()) exit;
/// @description Refresh, scroll and handle clicks

overlay_alpha = lerp(overlay_alpha, 1, 0.15)

refresh_timer -= 1
if (refresh_timer <= 0) {
	refresh_timer = 90
	friends = net_friends_list()
}

if (timing_mouse_wheel_down()) scroll_target += row_h
if (timing_mouse_wheel_up()) scroll_target -= row_h
scroll_target = clamp(scroll_target, 0, scroll_max)
scroll = clamp(lerp(scroll, scroll_target, 0.25), 0, scroll_max)
net_friends_panel_layout()

// Esc / B close. The destroy waits for End Step so o_esc never sees the same press.
if (timing_keyboard_pressed(vk_escape) || gamepad_ui_pressed(gp_face2)) {
	close_requested = true
	exit
}

if (input_delay > 0) {
	input_delay -= 1
	exit
}

var _mx = device_mouse_x_to_gui(0)
var _my = device_mouse_y_to_gui(0)
if (timing_mouse_pressed(mb_left) || gamepad_ui_pressed(gp_face1)) {
	var _hover = net_friends_panel_hover(_mx, _my)
	if (_hover >= 0) {
		net_friends_panel_action(buttons[_hover])
	} else if (timing_mouse_pressed(mb_left) && !point_in_rectangle(_mx, _my, px0, py0, px1, py1)) {
		close_requested = true
	}
}
