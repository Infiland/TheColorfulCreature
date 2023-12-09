var camx = camera_get_view_x(view_camera[0])
var camy = camera_get_view_y(view_camera[0])

x = camx + 96
y = camy + 110
if global.LEMode = 2 { 	draw_set_alpha(0) 
	alpha = 0 }

draw_sprite_ext(s_LEBuild,0,x,y,1,1,0,c_white,alpha)
if global.LEBuild = 1 {
alpha = 1	
} else { alpha = 0.5 }