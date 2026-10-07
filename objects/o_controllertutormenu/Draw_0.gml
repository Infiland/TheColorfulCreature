if (platform_mobile() && (room == r_settings || instance_exists(o_settingspausemenu))) exit;
if (platform_mobile() && (!instance_exists(o_fullscreensystem) || o_fullscreensystem.controllermode != 1)) exit;
if gamepad_ui_connected() {
draw_set_font(global.deathfont)
draw_controller_scheme(0,0,57,"Move")
draw_controller_scheme(0,64,5,"Accept")
draw_controller_scheme(0,128,7,"Back")
}
