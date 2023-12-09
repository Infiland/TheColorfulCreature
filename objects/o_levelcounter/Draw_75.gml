if instance_exists(o_settingspausemenu) { exit }

image_alpha = 1
if instance_exists(o_player) {
if o_player.x < camera_get_view_x(view_camera[0])+64 + string_width(string(global.endlesslevel)) {
if o_player.y > camera_get_view_y(view_camera[0])+672 {
image_alpha = 0.2
}}}
draw_set_alpha(image_alpha)

depth = -10000
draw_set_font(global.deathfont)
draw_set_color(c_white)
draw_sprite_ext(s_levelhud,0,17,653,0.38,0.38,0,c_white,1)	
draw_text(64,660,string(global.endlesslevel))
switch(global.endlessrunmode) {
case(1):
if global.newendlesslevelhighscore < global.endlesslevel {
draw_set_color(c_yellow)
draw_text(70 + string_width(global.endlesslevel),660,loc(316))	
}
break;
case(2):
if global.endlesslevelhighscore < global.endlesslevel {
draw_set_color(c_yellow)
draw_text(70 + string_width(global.endlesslevel),660,loc(316))	
}
break;
}

draw_set_alpha(1)