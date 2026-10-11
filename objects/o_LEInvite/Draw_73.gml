var _builders = 1
if (net_coop_is_host()) _builders += ds_map_size(global.net_coop_guests)
else if (net_coop_is_guest()) _builders = 2

draw_set_alpha(ui_draw_alpha)
draw_set_color(hover ? $3a3a5a : $2a2a2a)
draw_rectangle(x, y, x + 49, y + 49, false)
draw_set_color(hover ? $00aaff : $888888)
draw_rectangle(x, y, x + 49, y + 49, true)
// Two builders
draw_set_color(c_white)
draw_circle(x + 18, y + 17, 6, false)
draw_rectangle(x + 9, y + 26, x + 27, y + 38, false)
draw_set_color(net_coop_is_host() || net_coop_is_guest() ? $00aaff : $bbbbbb)
draw_circle(x + 32, y + 17, 6, false)
draw_rectangle(x + 23, y + 26, x + 41, y + 38, false)
if (_builders > 1) {
	draw_set_color($00aaff)
	draw_circle(x + 43, y + 7, 8, false)
	draw_set_color(c_black)
	draw_set_font(fnt_multiplayerfont)
	draw_set_halign(fa_center)
	draw_set_valign(fa_middle)
	draw_text(x + 43, y + 7, string(_builders))
}
if (hover && ui_draw_alpha > 0) {
	draw_set_font(fnt_multiplayerfont)
	draw_set_halign(fa_center)
	draw_set_valign(fa_top)
	draw_set_color(c_black)
	draw_text(x + 26, y + 57, loc("NET_COOP_TITLE"))
	draw_set_color(c_white)
	draw_text(x + 25, y + 56, loc("NET_COOP_TITLE"))
}
draw_set_halign(fa_left)
draw_set_valign(fa_top)
draw_set_color(c_white)
draw_set_alpha(1)
