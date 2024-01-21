if global.customizeselect = 3 {
image_alpha = 0.5
image_index = 0
} else {
image_alpha = 1	
}

if image_index = 1 {
if gamepad_button_check_pressed(0,gp_face1) {
event_perform(ev_mouse,ev_left_press)	
}}