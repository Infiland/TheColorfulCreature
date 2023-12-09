var camx = camera_get_view_x(view_camera[0])
var camy = camera_get_view_y(view_camera[0])

x = camx + 603
y = camy + 34

draw_sprite_ext(s_LEModeChanger,image_index,x,y,image_xscale,image_yscale,0,c_white,alpha)

alpha = 1
if global.writingmode = 1 { alpha = 0.5 }