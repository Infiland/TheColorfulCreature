draw_set_alpha(1)
draw_set_font(global.coolfont)
if global.writingmode = 1 {
draw_set_color(c_yellow)
draw_text_ext(10,84,text,32,1000)
draw_set_color(c_white)
draw_text(10,64,loc(140)+" "+loc(65))
} else {
draw_set_color(c_white)
draw_text_scribble_ext(10,64,global.leveleditorstring,1000)
//draw_text_scribble_ext(10,128,delete_timer,1000)
}