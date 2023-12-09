var camx = camera_get_view_x(view_camera[0])
var camy = camera_get_view_y(view_camera[0])
draw_sprite_ext(s_LEThumbnail,image_index,371+ camx,9 + camy,image_xscale,image_yscale,0,c_white,alpha)
x = camx + 371
y = camy + 9

if global.LEMode = 1 { alpha = 1 } else
{ alpha = 0.5 }