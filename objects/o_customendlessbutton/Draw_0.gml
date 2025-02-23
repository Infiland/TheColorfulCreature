scr_custombutton()
if global.customERunlock = 0 {
draw_set_font(global.deathfont)
draw_set_halign(fa_center)
draw_set_color(c_white)
if os_type = os_android || os_type = os_gxgames {
draw_text(x+118,y+122,"500              Required")
} else {
draw_text(x+118,y+122,"200              Required")
}
draw_sprite_ext(s_creditscurrency,0,x+60,y+122,2,2,0,c_white,1)
}
draw_set_halign(fa_left)