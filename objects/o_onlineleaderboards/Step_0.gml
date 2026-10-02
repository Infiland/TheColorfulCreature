if (!timing_instance_step()) exit;
if timing_keyboard_pressed(vk_right) || gamepad_ui_pressed(gp_padr) {
	global.leaderboardselect += 1
	reloadleaderboards()
	scroll = 0
}
if timing_keyboard_pressed(vk_left) || gamepad_ui_pressed(gp_padl) {
	global.leaderboardselect -= 1
	reloadleaderboards()
	scroll = 0
}

	if global.leaderboardselect < minselect {
global.leaderboardselect = maxselect
reloadleaderboards()
}
if global.leaderboardselect > maxselect {
	global.leaderboardselect = minselect
	reloadleaderboards()
}

if gamepad_ui_axis(gp_axisrv) < -0.2 || gamepad_ui_axis(gp_axisrv) > 0.2 { scroll += 10 * gamepad_ui_axis(gp_axisrv) }

if timing_mouse_wheel_down() {
scroll += 40	
}
if timing_mouse_wheel_up() {
scroll -= 40	
}
if scroll < 0 { scroll = 0 }
if scroll > 1450 { scroll = 1450 }