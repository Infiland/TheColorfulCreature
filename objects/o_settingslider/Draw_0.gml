// Draw label text
draw_set_alpha(1)
draw_set_font(global.coolfont)
draw_set_color(c_white)
draw_set_halign(fa_left)
draw_set_valign(fa_center)
draw_text(beginx - 80, y + 8, loc(slider_label))

// Draw slider track
var _cx = camera_get_view_x(view_camera[0])
var _track_y = y + 8
draw_set_color(make_color_rgb(80, 80, 80))
draw_line_width(beginx, _track_y, endx, _track_y, 3)

// Draw filled portion
draw_set_color(c_white)
draw_line_width(beginx, _track_y, x, _track_y, 3)

// Draw handle
draw_set_color(c_white)
draw_rectangle(x - 4, y, x + 4, y + 16, false)

// Draw percentage text when grabbing
if grab = true {
	draw_set_font(global.coolfont)
	draw_set_color(c_white)
	var _vol = variable_global_get(slider_gvar)
	if _vol > 0 && _vol < 1 {
		draw_text(x - 15, y + 20, string_format(_vol * 100, 0, 0) + "%")
	}
	if _vol = 0 { draw_text(x - 20, y + 20, "quiet") }
	if _vol = 1 { draw_text(x - 20, y + 20, "LOUD") }
}
