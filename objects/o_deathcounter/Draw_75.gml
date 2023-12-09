if instance_exists(o_settingspausemenu) { exit }
image_alpha = 1
if instance_exists(o_player) {
if o_player.x < camera_get_view_x(view_camera[0])+64 + string_width(string(global.deaths)) {
if o_player.y > camera_get_view_y(view_camera[0])+704 {
image_alpha = 0.2
}}}
draw_set_alpha(image_alpha)

depth = -10000
draw_set_font(global.deathfont)
if room != r_tale {
	
if room = r_leveleditor {
if global.LEMode != 2 {
exit;	
}}

shake = 0
draw_set_color(c_white)
if !instance_exists(o_player) {
if global.pause = 0 {
	shake = 5
draw_set_color(c_red)
}
}
if global.hardmode = 0 {
if global.endless = 0 {
draw_sprite_ext(s_skull,0,15+random_range(shake,-shake),723+random_range(shake,-shake),0.38,0.38,0,c_white,image_alpha)	
draw_text(room_width-room_width+64+random_range(shake,-shake),731+random_range(shake,-shake),string_hash_to_newline(string(global.deaths)))
draw_set_color(c_white)
}}
//Endless
if global.hardmode = 0 {
if global.endless = 1 {
draw_sprite_ext(s_heart,0,15+random_range(shake,-shake),723+random_range(shake,-shake),0.38,0.38,0,c_white,image_alpha)
draw_text(room_width-room_width+64+random_range(shake,-shake),731+random_range(shake,-shake),string_hash_to_newline(string(global.hardmodelives - global.deaths)))
draw_set_color(c_white)
}}

//Hard mode
if global.hardmode = 1 {
if global.endless = 0 {
draw_sprite_ext(s_heart,0,15+random_range(shake,-shake),723+random_range(shake,-shake),0.38,0.38,0,c_white,image_alpha)	
draw_text(room_width-room_width+64+random_range(shake,-shake),731+random_range(shake,-shake),string_hash_to_newline(string(global.hardmodelives - global.deaths)))
draw_set_color(c_white)
if global.infinitelivessettings = 0 {
if global.deaths > global.hardmodelives - 1 {
room_goto(r_hardmodedeathroom)
}} else { global.hardmodelives = "Infinite" }
}}

//Legendary Skin Color
if instance_exists(o_player) {
if global.skinselected = 10 or global.skinselected = 12 or global.skinselected = 17 {
draw_set_color(c_white)
if global.color = 0 { draw_text(850,734,"Color: Red") }
if global.color = 1 { draw_text(850,734,"Color: Yellow") }
if global.color = 2 { draw_text(850,734,"Color: Green") }
if global.color = 3 { draw_text(850,734,"Color: Blue") }
if global.color = 4 { draw_text(850,734,"Color: White") }
}}

}
draw_set_alpha(1)