draw_set_font(global.completefont)
//draw_set_font(global.langfont)

draw_set_halign(fa_center)
draw_set_alpha(1)
var textlayer = 0

for(textlayer = 0;textlayer < 5;textlayer++) {
draw_set_color(make_color_rgb(100 + 32 * textlayer,100 + 32 * textlayer,100 + 32 * textlayer))
draw_text((camera_get_view_x(view_camera[0])) + 512 + ((changex*dist) * textlayer),(90 - ui_draw_texty) + ((changey*dist) * textlayer),text)
}
draw_set_halign(fa_left)
