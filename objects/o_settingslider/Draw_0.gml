if (platform_mobile()) {
    var _saved_x = x;
    x = mobile_card_x;
    var _value = variable_global_get(slider_gvar);
    settings_mobile_draw_card(settings_text(slider_label), "");
    // Label above the track; no text crosses its touch area.
    draw_set_color(make_color_rgb(12, 12, 12));
    draw_rectangle(x + 2, y + 2, x + mobile_card_width - 2, y + mobile_card_height - 2, false);
    draw_set_font(fnt_mainmenu); draw_set_halign(fa_left); draw_set_valign(fa_middle); draw_set_color(c_white);
    var _label = settings_text(slider_label);
    var _scale = min(0.65, (mobile_card_width - 130) / max(1, string_width(_label)));
    draw_text_transformed(x + 20, y + 26, _label, _scale, _scale, 0);
    draw_set_halign(fa_right);
    draw_text_transformed(x + mobile_card_width - 20, y + 26, string(round(_value * 100)) + "%", 0.60, 0.60, 0);
    draw_set_color(c_gray); draw_line_width(beginx, y + 73, endx, y + 73, 8);
    draw_set_color(c_aqua); draw_line_width(beginx, y + 73, _saved_x, y + 73, 8);
    draw_circle(_saved_x, y + 73, 14, false);
    draw_set_halign(fa_left); draw_set_valign(fa_top); draw_set_color(c_white);
    x = _saved_x;
    exit;
}
// Only draw when submenu is active
if global.choosesettings != slider_menu { exit }

// Draw label text
draw_set_alpha(1)
draw_set_font(global.coolfont)
draw_set_color(c_white)
draw_set_halign(fa_left)
draw_set_valign(fa_center)
draw_text(beginx - 80, y + 8, settings_text(slider_label))

// Draw slider track
var _track_y = y + 8
draw_set_color(make_color_rgb(80, 80, 80))
draw_line_width(beginx, _track_y, endx, _track_y, 3)

// Draw filled portion
draw_set_color(c_white)
draw_line_width(beginx, _track_y, x, _track_y, 3)

// Draw handle
draw_set_color(c_white)
draw_rectangle(x - 4, y, x + 4, y + 16, false)

// Draw value text when grabbing
if grab || global.soundchange == slider_soundchange_id {
	draw_set_font(global.coolfont)
	draw_set_color(c_white)
	if slider_integer {
		draw_text(x - 15, y + 20, string(variable_global_get(slider_gvar)))
	} else {
		var _vol = variable_global_get(slider_gvar)
		if _vol > 0 && _vol < 1 {
			draw_text(x - 15, y + 20, string_format(_vol * 100, 0, 0) + "%")
		}
		if _vol = 0 { draw_text(x - 20, y + 20, "quiet") }
		if _vol = 1 { draw_text(x - 20, y + 20, "LOUD") }
	}
}

draw_set_valign(fa_top);
