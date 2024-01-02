y = ystart - yscroll

if gamepad_axis_value(0,gp_axisrv) < -0.2 || gamepad_axis_value(0,gp_axisrv) > 0.2 { yscroll += 18*gamepad_axis_value(0,gp_axisrv) }

if mouse_wheel_up() {
	yscroll -= 45
}
if mouse_wheel_down() {
	yscroll += 45
}

if yscroll < 0 { yscroll = 0 }
if yscroll > 500 { yscroll = 500 }

if text != "???" {
level = real(text)
}

if global.worldProgression >= level {
locked = 0
} else { locked = 1 }