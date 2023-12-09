var camx = camera_get_view_x(view_camera[0])
var camy = camera_get_view_y(view_camera[0])

if isleft = 0 {
draw_sprite_ext(s_skinpagebuttonright,0,533 + camx,35 + camy,0.5,1,0,c_white,alpha)
x = 533 + camx
} else {
draw_sprite_ext(s_skinpagebuttonright,0,152 + camx,35 + camy,-0.5,1,0,c_white,alpha)
x = 152 + camx
}

y = 35 + camy