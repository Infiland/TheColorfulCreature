if onmouse = 1 {
	scale = 1.5
} else {
	scale = 1
}

if onmouse = 1 {
if gamepad_button_check_released(0,gp_face1) {
event_perform(ev_mouse,ev_left_press)	
}}

image_xscale = lerp(image_xscale,scale,0.1 * (60 / global.maxfps))
image_yscale = lerp(image_yscale,scale,0.1 * (60 / global.maxfps))