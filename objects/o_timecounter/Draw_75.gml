if instance_exists(o_settingspausemenu) { exit }

image_alpha = 1
if instance_exists(o_player) {
if o_player.x < camera_get_view_x(view_camera[0])+64 + string_width(string(string_format(global.time,1,2 - global.decimalsettings))) {
if o_player.y > camera_get_view_y(view_camera[0])+672 {
image_alpha = 0.2
}}}
draw_set_alpha(image_alpha)

depth = -10000
if room != r_tale {
draw_set_font(global.deathfont)
draw_set_color(c_white)
if global.hardmodedifficulty <= 5 {
draw_sprite_ext(s_time,image_index,18,690,0.33,0.33,0,c_white,1)
draw_text(room_width-room_width+64,696,string_hash_to_newline(string_format(global.time,1,2 - global.decimalsettings)))
} else {
draw_sprite_ext(s_time,dynamictimeindex,18,690,0.33,0.33,0,c_white,1)
draw_text(room_width-room_width+64,696,string(string_format(global.timeleftHM - global.time,1,2-global.decimalsettings))) 

}
}

draw_set_alpha(1)