draw_set_alpha(0.5)
draw_rectangle_color(0,0,2000,2000,c_black,c_black,c_black,c_black,false)
draw_set_alpha(1)

draw_rectangle_color(200,y,824,y+50,c_black,c_black,c_black,c_black,false)
draw_rectangle(200,y,824,y+50,true)
draw_set_font(global.deathfont)
draw_set_halign(fa_center)
draw_text_ext(512,y+13,text,20,1000)
y = lerp(y,384,0.2 * (60 / global.maxfps))
draw_set_halign(fa_left)

if gamepad_button_check_pressed(0,gp_face1) {
event_perform(ev_keypress,ord("Y"))	
}
if gamepad_button_check_pressed(0,gp_face2) {
event_perform(ev_keypress,ord("N"))	
}

if os_type = os_android {
if instance_exists(o_buttonandroidyes) and instance_exists(o_buttonandroidno)
	if o_buttonandroidyes.press = 1 {
		url_open(url)
		instance_destroy()
		instance_destroy(o_buttonandroidyes)
		instance_destroy(o_buttonandroidno)
	}
	if o_buttonandroidno.press = 1 {
		instance_destroy()
		instance_destroy(o_buttonandroidyes)
		instance_destroy(o_buttonandroidno)
	}}