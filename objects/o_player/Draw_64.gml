/*draw_set_color(c_white)
draw_rectangle(bbox_left,bbox_bottom,bbox_right,bbox_top,true)
draw_text(x,y+10,direction)*/

if global.vignettesettings = 1 {
draw_set_alpha(0.5)
draw_sprite(s_vignettebackround,0,0,0)
draw_set_alpha(1)
}