scr_custombutton()
draw_set_halign(fa_left)
draw_set_color(c_white)
if room = r_endlessrunmenu {
if global.newendlesslevelhighscore > 0 {
draw_set_font(global.deathfont)
draw_text(x,y+122, string(loc(38)) + ": "+string(global.newendlesslevelhighscore))
}}