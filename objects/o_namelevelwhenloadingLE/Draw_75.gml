draw_set_alpha(0.5)
draw_rectangle_color(0,0,room_width,room_height,c_black,c_black,c_black,c_black,false)
draw_set_font(global.gamemodefont)
draw_set_alpha(1)
draw_set_halign(fa_center)
draw_text(512,100,loc("WHAT_LEVEL_DO_YOU_WANT_TO_LOAD"))
var directory = directory_set("/LevelEditor Files//" + text + "/")
if directory_exists(directory) {
draw_set_color(c_lime)
} else { draw_set_color(c_red) }
draw_text(512,200,text)

if !directory_exists(directory) {
draw_set_color(c_white)
draw_set_font(global.deathfont)
if text != "" {
draw_text(512,270,loc("WARNING_THIS_LEVEL_DOESN_T_EXIST")) }}

draw_set_color(c_white)
draw_set_font(global.gamemodefont)
draw_set_color(c_white)
draw_text(512,300,loc("PRESS_ENTER_WHEN_YOU_ARE_DONE")+".\n"+loc("PRESS_ESC_TO_CANCEL"))
draw_set_halign(fa_left)