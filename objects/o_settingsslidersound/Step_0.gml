if global.choosesettings = 2 {
if grab = true {
	x = mouse_x
	global.soundvolume = (x - beginx) / 146
	if global.soundvolume < 0 { global.soundvolume = 0 }
	if global.soundvolume > 1 { global.soundvolume = 1 }
	}

if global.soundchange = 2 {
image_speed = 1	
}
if global.soundchange = 0 {
image_index = 0	
image_speed = 0
}
if device_mouse_check_button_released(0,mb_left) {
grab = false
global.soundchange = 0
}
}
if global.choosesettings != 2 { x = lerp(x,camera_get_view_x(view_camera[0])-256,0.2 * (60 / global.maxfps)) }
if global.choosesettings = 2 {
x = beginx + (global.soundvolume * 146)
}