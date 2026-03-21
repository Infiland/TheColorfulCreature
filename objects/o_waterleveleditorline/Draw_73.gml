draw_set_alpha(1)
depth = -100

// Use snapped position for preview when grid is enabled
var _mx = mouse_x;
var _my = mouse_y;
if (instance_exists(o_LEgrid) && o_LEgrid.grid == 1) {
	_mx = round(mouse_x / 32) * 32;
	_my = round(mouse_y / 32) * 32;
}

if clicked = 0 { draw_circle(_mx, _my, 5, c_white) }
if clicked > 0 {
if bad = 0 {
draw_line_width_color(x1, y1, _mx, _my, 5, c_blue, c_purple)
draw_set_alpha(0.2)
draw_rectangle_color(x1, y1, _mx, _my, c_gray, c_white, c_gray, c_white, false)
} else { 
	draw_line_width_color(x1, y1, _mx, _my, 5, c_red, c_red)
	draw_set_alpha(0.2)
	draw_rectangle_color(x1, y1, _mx, _my, c_red, c_red, c_red, c_red, false)
	}
}