if os_type = os_android {
for(var i=0;i<6;i++) {
	if device_mouse_check_button_pressed(i,mb_any) {
		with(instance_create(device_mouse_x(i),device_mouse_y(i),o_indicatorandroid)) {
		my_touch = i	
		}
	}
}
} else {
steam_update()	
}

if gamepad_axis_value(0,gp_axislh) > 0.2 || gamepad_axis_value(0,gp_axislh) < -0.2 {
	controllermode = 1
	if  ingame = 0 {
mConX += 10 * gamepad_axis_value(0,gp_axislh)
	}
}
if gamepad_axis_value(0,gp_axislv) > 0.2 || gamepad_axis_value(0,gp_axislv) < -0.2 {
	controllermode = 1
	if  ingame = 0 {
mConY += 10 * gamepad_axis_value(0,gp_axislv)
	}
}
if controllermode = 1 {
if  ingame = 0 {
window_mouse_set(mConX,mConY)
}

if instance_exists(o_player) {
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
if !gamepad_is_connected(0) { controllermode = 0 }