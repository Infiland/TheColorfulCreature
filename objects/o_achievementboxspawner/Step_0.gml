if mouse_wheel_up() {
scroll -= 150	
}
if mouse_wheel_down() {
scroll += 150	
}

if scroll < 0 { scroll = 0 }
if scroll > scrollcap { scroll = scrollcap }

if tcc_gamepad_axis_value(0,gp_axisrv) < -0.2 || tcc_gamepad_axis_value(0,gp_axisrv) > 0.2 { scroll += 25 * tcc_gamepad_axis_value(0,gp_axisrv) }

global.achievementsscroll = lerp(global.achievementsscroll,scroll,0.2*(60/global.maxfps))