draw_self()
draw_set_halign(fa_center)
draw_set_font(global.coolfont)
draw_set_color(c_white)
controls_key_display(global.controlsinteract)
if instance_place(x,y,o_player) {
if global.levelselect = 0 {
if used = false {
if crash != 6969 {
draw_text(390,375,"Press [" + string(keyd) + "] to convert coins into credits.")
} else { draw_text(390,375,loc(607)) }
} else {
draw_text(390,375,"Thanks for depositing your coins!")		
}} else {
	draw_text(390,375,loc(606))	
}
}