draw_set_alpha(0.9)
var camx = camera_get_view_x(view_camera[0])
var camy = camera_get_view_y(view_camera[0])


draw_rectangle_color(0,0,room_width,room_height,c_black,c_black,c_black,c_black,false)
draw_set_font(global.gamemodefont)
draw_set_alpha(1)
draw_set_color(c_white)
draw_set_halign(fa_center)
draw_text(512+camx,100+camy,"Item Menu")
draw_set_font(global.deathfont)

draw_set_color(c_white)
draw_text(512+camx,730+camy,"You can press ENTER/ESC to leave!")
draw_set_halign(fa_left)