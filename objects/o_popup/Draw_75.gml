draw_set_alpha(0.6)
draw_rectangle_color(0, 0, 2000, 2000, c_black, c_black, c_black, c_black, false)
draw_set_alpha(1)

draw_set_color(c_black)
draw_rectangle_color(box_x1, box_y, box_x2, box_y + box_h, c_black, c_black, c_black, c_black, false)
draw_set_color(c_white)
draw_rectangle(box_x1, box_y, box_x2, box_y + box_h, true)

draw_set_font(global.deathfont)
draw_set_halign(fa_center)
draw_set_valign(fa_top)

var text_y = box_y + 25
if title != "" {
	draw_text_transformed(512, box_y + 10, title, 1.2, 1.2, 0)
	text_y = box_y + 55
}
draw_text_scribble_ext(512, text_y, message, 560)

draw_set_halign(fa_left)
draw_set_valign(fa_top)
draw_set_color(c_white)

