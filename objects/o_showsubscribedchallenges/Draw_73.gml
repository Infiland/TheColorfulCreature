draw_set_color(c_white)
draw_set_alpha(0.5)
draw_rectangle_color(0,0,1024,768,c_black,c_black,c_black,c_black,false)
draw_set_alpha(1)
draw_set_font(global.deathfont)
draw_text(16,700,"Subscribed Workshop Challenges")

if mouse_wheel_up() {
	global.workshopchallenges_scroll -= 60
}
if mouse_wheel_down() {
	global.workshopchallenges_scroll += 60
}

if global.workshopchallenges_scroll < 0 {
	global.workshopchallenges_scroll = 0	
}
if global.workshopchallenges_scroll > global.workshopchallenges_scrollmax {
	global.workshopchallenges_scroll = global.workshopchallenges_scrollmax	
}

if keyboard_check_pressed(vk_escape) {
	with (o_workshopchallengeitembutton) instance_destroy()
	instance_destroy()
}

