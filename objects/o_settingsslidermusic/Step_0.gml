if global.choosesettings = 2 {
if grab = true {
	x = mouse_x
	global.musicvolume = (x - beginx) / 146
	if global.musicvolume < 0 { global.musicvolume = 0 }
	if global.musicvolume > 1 { global.musicvolume = 1 }
	}

if global.soundchange = 1 {
image_speed = 1	
}
if global.soundchange = 0 {
image_index = 0	
image_speed = 0
}

if global.infosettings = 6 {
if gamepad_button_check_pressed(0,gp_face1) {
event_perform(ev_mouse,ev_left_press)	
}}

if device_mouse_check_button_released(0,mb_left) || gamepad_button_check_released(0,gp_face1) {
grab = false
global.soundchange = 0
}}
if global.choosesettings != 2 { x = lerp(x,camera_get_view_x(view_camera[0])-256,0.2 * (60 / global.maxfps)) }
if global.choosesettings = 2 {
x = beginx + (global.musicvolume * 146)
}