draw_set_alpha(1)
depth = -100
if clicked = 0 { draw_circle(mouse_x,mouse_y,5,c_white) }
if clicked > 0 {
if bad = 0 {
draw_line_width_color(x1,y1,mouse_x,mouse_y,5,c_blue,c_purple)
draw_set_alpha(0.2)
draw_rectangle_color(x1,y1,mouse_x,mouse_y,c_gray,c_white,c_gray,c_white,false)
} else { 
	draw_line_width_color(x1,y1,mouse_x,mouse_y,5,c_red,c_red)
	draw_set_alpha(0.2)
	draw_rectangle_color(x1,y1,mouse_x,mouse_y,c_red,c_red,c_red,c_red,false)
	}
}