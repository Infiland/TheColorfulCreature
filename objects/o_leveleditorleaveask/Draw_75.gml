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

if os_type = os_android {
if instance_exists(o_buttonandroidyes) and instance_exists(o_buttonandroidno)
	if o_buttonandroidyes.press = 1 {
		audio_stop_all()
instance_destroy(o_ammocounter)
instance_destroy(o_deathcounter)
instance_destroy(o_musicdistortion)
instance_destroy(o_smoothcamera)
room_goto(r_mainmenu)
room_set_width(r_leveleditor,1024)
room_set_height(r_leveleditor,768)
global.LES = 0
		instance_destroy()
		instance_destroy(o_buttonandroidyes)
		instance_destroy(o_buttonandroidno)
	}
	if o_buttonandroidno.press = 1 {
		instance_destroy()
		instance_destroy(o_buttonandroidyes)
		instance_destroy(o_buttonandroidno)
	}}