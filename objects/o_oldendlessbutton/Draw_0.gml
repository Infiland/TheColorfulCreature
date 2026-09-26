scr_custombutton()
if global.oldERunlock = 1 {
draw_set_color(c_white)
draw_set_halign(fa_left)
if room = r_endlessrunmenu {
if global.endlesslevelhighscore > 0 {
draw_set_font(global.deathfont)
draw_text(x,y+122,loc("HIGHSCORE") + ": "+string(global.endlesslevelhighscore))
}}
} else {
draw_set_font(global.deathfont)
draw_set_halign(fa_center)
draw_set_color(c_white)
draw_text(x+118,y+122,string(cost) + "              Required")
draw_sprite_ext(s_creditscurrency,0,x+60,y+122,2,2,0,c_white,1)
}
draw_set_halign(fa_left)
