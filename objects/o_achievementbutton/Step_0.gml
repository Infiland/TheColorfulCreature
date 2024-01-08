if rotate = 0 { image_angle = lerp(image_angle,0,0.2 * global.delta) }
if rotate = 1 { image_angle = lerp(image_angle,10,0.2 * global.delta) }

//Controller
if rotate = 1 {
if gamepad_button_check_pressed(0,gp_face1) {
event_perform(ev_mouse,ev_left_press)	
}}