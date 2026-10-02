// The selected frame and URL follow logical updates; native animation must
// not change which advertisement is presented between those updates.
var _frames = sprite_get_number(sprite_index)
var _frame = (game - 1 + _frames) mod _frames
draw_sprite_ext(sprite_index,_frame,x,y,image_xscale,image_yscale,image_angle,image_blend,image_alpha)
