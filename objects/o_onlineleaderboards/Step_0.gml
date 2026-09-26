if keyboard_check_pressed(vk_right) || tcc_gamepad_button_check_pressed(0,gp_padr) {
	global.leaderboardselect += 1
	reloadleaderboards()
	scroll = 0
}
if keyboard_check_pressed(vk_left) || tcc_gamepad_button_check_pressed(0,gp_padl) {
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

if tcc_gamepad_axis_value(0,gp_axisrv) < -0.2 || tcc_gamepad_axis_value(0,gp_axisrv) > 0.2 { scroll += 10 * tcc_gamepad_axis_value(0,gp_axisrv) }

if mouse_wheel_down() {
scroll += 40	
}
if mouse_wheel_up() {
scroll -= 40	
}
if scroll < 0 { scroll = 0 }
if scroll > 1450 { scroll = 1450 }