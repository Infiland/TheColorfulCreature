if (TCC_MOBILE_SMOKE) scr_mobile_smoke_step();
platform_services_flush();
if (platform_steam()) tcc_steam_update();

if tcc_gamepad_axis_value(0,gp_axislh) > 0.2 || tcc_gamepad_axis_value(0,gp_axislh) < -0.2 {
	controllermode = 1
	if  ingame = 0 {
mConX += 10 * tcc_gamepad_axis_value(0,gp_axislh)
	}
}
if tcc_gamepad_axis_value(0,gp_axislv) > 0.2 || tcc_gamepad_axis_value(0,gp_axislv) < -0.2 {
	controllermode = 1
	if  ingame = 0 {
mConY += 10 * tcc_gamepad_axis_value(0,gp_axislv)
	}
}
if controllermode = 1 {
if  ingame = 0 {
window_mouse_set(mConX,mConY)
}

if instance_exists(o_player) || instance_exists(o_playerMU) {
if global.pause = 0 {
	ingame = 1
window_set_cursor(cr_none)
} else {
ingame = 0
window_set_cursor(cr_default)
}
}

} else {
	mConX = mouse_x
	mConY = mouse_y
}

if mouse_check_button(mb_any) { controllermode = 0 }
if !tcc_gamepad_is_connected(0) { controllermode = 0 }
