if instance_exists(o_player) {
if distance_to_object(o_player) > 1300 {
exit
}}
if global.visual3dsettings = 1 {
if global.pause = 0 {
draw_sprite_pos(s_bluepassblock,0,x-hdepth,y-vdepth,x+32-hdepth,y-vdepth,x+32-hdepth,y+32-vdepth,x-hdepth,y+32-vdepth,image_alpha);
}}