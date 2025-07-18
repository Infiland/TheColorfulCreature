if rotate = 0 {
if image_angle > 0 {	
	image_angle -= 10
	if move = 1 {
	x -= 2
	}
	if image_angle < 0.1 {
	image_angle = 0
	
	var distance = abs(x-950)
	
	if distance > 1000 {
		if !steam_get_achievement("SPINNNNN") { 
			steam_set_achievement("SPINNNNN") 
		}	
	}
	
	if x < 950 {
		steam_upload_score("Cog Distance", distance)
	} else if x < -450 {
		steam_upload_score_ext("Cog Distance", distance, true)
	}
	
	move = 0
	x = 960 + vx
	if room = r_mainmenu {
	y = 610 + vy
	} else {
	y = 704 + vy	
	}
	}
	}}
else 
{image_angle += 1}
if room != r_mainmenu {
if keyboard_check_pressed(vk_escape) || gamepad_button_check_pressed(0,gp_start) {
instance_destroy()
}}
//Controller
if rotate = 1 {
if gamepad_button_check_pressed(0,gp_face1) {
event_perform(ev_mouse,ev_left_press)	
}}