if (!timing_instance_step()) exit;
if timing_mouse_wheel_up() {
scroll -= 150	
}
if timing_mouse_wheel_down() {
scroll += 150	
}

if scroll < 0 { scroll = 0 }
if scroll > scrollcap { scroll = scrollcap }

if gamepad_ui_axis(gp_axisrv) < -0.2 || gamepad_ui_axis(gp_axisrv) > 0.2 { scroll += 25 * gamepad_ui_axis(gp_axisrv) }

global.achievementsscroll = lerp(global.achievementsscroll,scroll,0.2*(60/global.maxfps))