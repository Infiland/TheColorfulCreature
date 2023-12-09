/*x = 950 
y = 17
image_blend = c_white
if global.LEMode = 1 {
scr_leveleditorsprites(global.LES)
}*/
scr_leveleditorsprites(global.LES)
var camx = camera_get_view_x(view_camera[0])
var camy = camera_get_view_y(view_camera[0])
if global.LEMode = 2 {
	draw_set_alpha(0)
	}
x = 950 + camx
y = 17 + camy

//Look
image_blend = c_white
//
draw_sprite(sprite_index,-1,x,y)