var camx = camera_get_view_x(view_camera[0])
var camy = camera_get_view_y(view_camera[0])

x = camx + 149
y = camy + 110

draw_sprite_ext(s_LEBackgrounds,0,x,y,1,1,0,c_white,alpha)
if global.LEBuild = 2 {
alpha = 1	
} else { alpha = 0.5 }

if global.LEMode = 2 { alpha = 0 }