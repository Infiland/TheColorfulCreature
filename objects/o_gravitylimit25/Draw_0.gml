if instance_exists(o_player) {
if distance_to_object(o_player) > 1300 {
exit
}}
depth = -10;
if global.visual3dsettings = 0 {
draw_self();
}
if global.visual3dsettings = 1 {
if global.pause = 1 {
draw_self();
}
if global.pause = 0 {
if image_alpha > 0 {
// LEFT
if hdepth < 0 {
draw_sprite_pos(sprite_index,0,x,y,x-hdepth,y-vdepth,x-hdepth,y+32-vdepth,x,y+32,image_alpha);
}
// RIGHT
if hdepth > 0 {
draw_sprite_pos(sprite_index,0,x+32,y,x+32-hdepth,y-vdepth,x+32-hdepth,y+32-vdepth,x+32,y+32,image_alpha);
}
// TOP
if vdepth < 0 {
draw_sprite_pos(sprite_index,0,x-hdepth,y-vdepth,x+32-hdepth,y-vdepth,x+32,y,x,y,image_alpha);
}
// BOTTOM
if vdepth > 0 {
draw_sprite_pos(sprite_index,0,x-hdepth,y+32-vdepth,x+32-hdepth,y+32-vdepth,x+32,y+32,x,y+32,image_alpha);
}
}}}