if object_index != o_namelevelLE {
exit;	
}
var camx = camera_get_view_x(view_camera[0])
var camy = camera_get_view_y(view_camera[0])

draw_set_alpha(0.5)
draw_rectangle_color(0,0,room_width,room_height,c_black,c_black,c_black,c_black,false)
draw_set_font(global.gamemodefont)
draw_set_alpha(1)
draw_set_halign(fa_center)
draw_text(camx+512,camy+100,loc(133))
var directory = working_directory + "/LevelEditor Files/" + "/" + text + "/"
if !directory_exists(directory) {
draw_set_color(c_lime)
} else { draw_set_color(c_yellow) }
draw_text(camx+512,camy+200,text)
if directory_exists(directory) {
draw_set_color(c_white)
draw_set_font(global.deathfont)
if text != "" {
draw_text(camx+512,camy+270,loc(141)) }} //warning this level exists
draw_set_color(c_white)
draw_set_font(global.gamemodefont)
draw_text(camx+512,camy+300,loc(65)+".\n"+loc(66))
draw_set_halign(fa_left)