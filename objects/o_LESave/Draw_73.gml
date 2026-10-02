draw_sprite_ext(s_LESave,image_index,x,y,image_xscale,image_yscale,0,c_white,ui_draw_alpha);

if global.LEMode = 1 {
if global.levelname = "" {
if image_index = 1 {
draw_set_font(global.coolfont)
draw_text(127,73,"You cannot save a level without a name. Name your level first!")	
}}}
