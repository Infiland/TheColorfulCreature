if (!timing_instance_step()) exit;
if (TCC_MOBILE_SMOKE) scr_mobile_smoke_step();
platform_services_flush();
if (platform_steam()) tcc_steam_update();

// This object persists when gameplay exits into a menu.
var _was_ingame = ingame;
ingame = (instance_exists(o_player) || instance_exists(o_playerMU)) && global.pause == 0;
if (_was_ingame && !ingame) window_set_cursor(cr_default);

// Match gameplay/settings selection, including another pad after disconnect.
var _device = gamepad_remap_active_device(true);
var _axis_h = _device < 0 ? 0 : tcc_gamepad_axis_value(_device, gp_axislh);
var _axis_v = _device < 0 ? 0 : tcc_gamepad_axis_value(_device, gp_axislv);
if (_device < 0) {
    if (controllermode == 1) window_set_cursor(cr_default);
    controllermode = 0;
}
// First controller activation continues from the current mouse position.
if (controllermode == 0 && (abs(_axis_h) > 0.2 || abs(_axis_v) > 0.2)) {
    mConX = mouse_x;
    mConY = mouse_y;
}

if _axis_h > 0.2 || _axis_h < -0.2 {
	controllermode = 1
	if  ingame = 0 {
mConX += 10 * _axis_h
	}
}
if _axis_v > 0.2 || _axis_v < -0.2 {
	controllermode = 1
	if  ingame = 0 {
mConY += 10 * _axis_v
	}
}
if controllermode = 1 {
if  ingame = 0 {
window_mouse_set(mConX,mConY)
}

window_set_cursor(ingame ? cr_none : cr_default)

} else {
	mConX = mouse_x
	mConY = mouse_y
}

if timing_mouse_down(mb_any) { controllermode = 0 }
