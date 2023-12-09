if rotate = 0 {
if image_angle > 0 {	
	image_angle -= 10
	if move = 1 {
	x -= 2
	}
	if image_angle < 0.1 {
	image_angle = 0
	if x < 950 {
	steam_upload_score("Cog Distance",abs(x-950))
	} else if x < -450 {
	steam_upload_score_ext("Cog Distance",abs(x-950),true)	
	}
	move = 0
	x = 960 + vx
	y = 704 + vy
	}
	}}
else 
{image_angle += 1}

if room != r_mainmenu {
if keyboard_check_pressed(vk_escape) || gamepad_button_check_pressed(0,gp_start) {
instance_destroy()
}}