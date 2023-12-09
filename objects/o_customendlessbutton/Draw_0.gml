if global.customERunlock = 1 {
scr_custombutton()
} else {
draw_sprite_ext(s_lockedbutton,0,x,y,2.36,2.36,0,c_white,1)
draw_set_font(global.deathfont)
draw_set_halign(fa_center)
draw_set_color(c_white)
if os_type = os_android {
draw_text(x+118,y+122,"500              Required")
} else {
draw_text(x+118,y+122,"200              Required")
}
draw_sprite_ext(s_creditscurrency,0,x+60,y+122,2,2,0,c_white,1)
}
draw_set_halign(fa_left)