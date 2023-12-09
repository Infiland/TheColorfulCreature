if instance_exists(o_settingspausemenu) { exit }

image_alpha = 1
if instance_exists(o_player) {
if o_player.x < camera_get_view_x(view_camera[0])+64 + string_width(string(global.gunammo)) {
if o_player.y > camera_get_view_y(view_camera[0])+600 {
image_alpha = 0.2
}}}
draw_set_alpha(image_alpha)

if instance_exists(o_gunequipped) {
depth = -10000
if global.pause = 1 { image_speed = 0 }
if global.pause = 0 { image_speed = 0.2 * (60 / global.maxfps) }
if room != r_tale {
draw_set_font(global.deathfont)
draw_set_color(c_white)
if global.gunammo < 1 {
draw_set_color(c_red)
}
if room != r_leveleditor {
if instance_exists(o_coincounter) or instance_exists(o_levelcounter) {
if global.gunammoinfinite = false { draw_text(64,625,string(global.gunammo))
draw_sprite_ext(s_ammo,image_index,20,618,1,1,0,c_white,1) }
if global.gunammoinfinite = true { draw_text(64,625,"Infinite")
draw_sprite_ext(s_ammoinfinite,image_index,20,618,1,1,0,c_white,1) }
} else {
if global.gunammoinfinite = false { draw_text(64,660,string(global.gunammo))
draw_sprite_ext(s_ammo,image_index,20,653,1,1,0,c_white,1) }
if global.gunammoinfinite = true { draw_text(64,660,"Infinite")
draw_sprite_ext(s_ammoinfinite,image_index,20,653,1,1,0,c_white,1)}	
}
} else {
if global.gunammoinfinite = false { draw_text(64,660,string(global.gunammo))
draw_sprite_ext(s_ammo,image_index,20,653,1,1,0,c_white,1) }
if global.gunammoinfinite = true { draw_text(64,660,"Infinite")
draw_sprite_ext(s_ammoinfinite,image_index,20,653,1,1,0,c_white,1) }
}
draw_set_color(c_white)
}
}

draw_set_alpha(1)