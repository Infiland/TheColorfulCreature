draw_set_alpha(0.5)
draw_rectangle_color(0,0,room_width,room_height,c_black,c_black,c_black,c_black,false)
draw_set_font(global.gamemodefont)
draw_set_alpha(1)
draw_set_halign(fa_center)
draw_text(512,100,loc(67))
var directory = working_directory + "/LevelEditor Files/" + "/" + text + "/"
if directory_exists(directory) {
draw_set_color(c_lime)
} else { draw_set_color(c_red) }
draw_text(512,200,text)

if !directory_exists(directory) {
draw_set_color(c_white)
draw_set_font(global.deathfont)
if text != "" {
draw_text(512,270,loc(142)) }}

draw_set_color(c_white)
draw_set_font(global.gamemodefont)
draw_set_color(c_white)
draw_text(512,300,loc(65)+".\n"+loc(66))
draw_set_halign(fa_left)