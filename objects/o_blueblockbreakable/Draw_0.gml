depth = -10;

if hidesprites = false {

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
draw_sprite_pos(s_blueblocksides,0,x,y,x-hdepth,y-vdepth,x-hdepth,y+(32*image_yscale)-vdepth,x,y+(32*image_yscale),image_alpha);
}
// RIGHT
if hdepth > 0 {
draw_sprite_pos(s_blueblocksides,0,x+(32*image_xscale),y,x+(32*image_xscale)-hdepth,y-vdepth,x+(32*image_xscale)-hdepth,y+(32*image_yscale)-vdepth,x+32*image_xscale,y+32*image_yscale,image_alpha);
}
// TOP
if vdepth < 0 {
draw_sprite_pos(s_blueblocksides,0,x-hdepth,y-vdepth,x+(32*image_xscale)-hdepth,y-vdepth,x+32*image_xscale,y,x,y,image_alpha);
}
// BOTTOM
if vdepth > 0 {
draw_sprite_pos(s_blueblocksides,0,x-hdepth,y+(32*image_yscale)-vdepth,x+(32*image_xscale)-hdepth,y+(32*image_yscale)-vdepth,x+(32*image_xscale),y+(32*image_yscale),x,y+(32*image_yscale),image_alpha);
}
}}}

}