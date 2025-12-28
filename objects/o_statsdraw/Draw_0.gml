draw_set_halign(fa_left)
draw_set_valign(fa_top)
draw_set_font(global.deathfont)

var bg_top = make_color_rgb(12, 14, 20)
var bg_bottom = make_color_rgb(4, 5, 8)
draw_set_alpha(1)
draw_rectangle_color(0, 0, room_width, room_height, bg_top, bg_top, bg_bottom, bg_bottom, false)

var header_x = stats_margin_x
var header_y = stats_header_y
var header_w = room_width - stats_margin_x * 2
var header_h = stats_header_h

draw_set_alpha(0.25)
draw_set_color(c_black)
draw_rectangle(header_x + 2, header_y + 2, header_x + header_w + 2, header_y + header_h + 2, false)

draw_set_alpha(0.9)
draw_rectangle_color(header_x, header_y, header_x + header_w, header_y + header_h, make_color_rgb(18, 20, 28), make_color_rgb(18, 20, 28), make_color_rgb(12, 14, 20), make_color_rgb(12, 14, 20), false)

draw_set_alpha(1)
draw_set_color(c_white)
draw_text(header_x + 16, header_y + 10, stats_label_rank + stats_rank_label)

draw_set_halign(fa_right)
draw_text(header_x + header_w - 16, header_y + 10, stats_label_full + stats_format_number(stats_game_progress, 0) + "%")
draw_set_halign(fa_left)

var xp_bar_x = header_x + 16
var xp_bar_y = header_y + 40
var xp_bar_w = header_w - 32
var xp_bar_h = 10

draw_set_alpha(0.2)
draw_set_color(c_black)
draw_rectangle(xp_bar_x, xp_bar_y, xp_bar_x + xp_bar_w, xp_bar_y + xp_bar_h, false)

draw_set_alpha(0.85)
draw_set_color(color)
draw_rectangle(xp_bar_x, xp_bar_y, xp_bar_x + xp_bar_w * stats_xp_fill, xp_bar_y + xp_bar_h, false)

draw_set_alpha(1)
draw_set_color(c_white)
draw_text(xp_bar_x, xp_bar_y + 14, "EXP " + stats_format_number(xp, 0))

if stats_scroll_max > 0 {
	draw_set_font(global.cool2font)
	draw_set_color(make_color_rgb(200, 200, 200))
	draw_set_halign(fa_right)
	draw_text(header_x + header_w - 16, header_y + header_h - 22, "Scroll to view more")
	draw_set_halign(fa_left)
	draw_set_font(global.deathfont)
}

var draw_y = stats_view_top - yscroll
var i = 0
for (i = 0; i < array_length(stats_categories); i++) {
	var cat = stats_categories[i]
	var card_h = stats_draw_category(cat, header_x, draw_y, header_w)
	draw_y += card_h + stats_card_gap
}

draw_set_alpha(1)
draw_set_color(c_white)
draw_set_halign(fa_left)
