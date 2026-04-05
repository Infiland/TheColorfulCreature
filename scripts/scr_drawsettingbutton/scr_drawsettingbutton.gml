/// @function scr_drawsettingbutton()
/// @description Draws a code-based settings button with state indicator icons
function scr_drawsettingbutton() {
	var xx = (x + 5 * image_xscale)
	var yy = (y + 5 * image_yscale)
	var xtxt = (x + xx) / 2
	var ytxt = (y + yy) / 2
	var _btn_w = xx - x
	var _btn_h = yy - y
	var _text_yoff = _btn_h * 0.06  // Push text down to visually center in button
	draw_set_font(fnt_mainmenu)
	var textlayer = 0
	draw_set_alpha(1)
	var a = 1 / image_alpha

	// Animate text jitter
	timer -= 1 * (60 / global.maxfps)
	if timer < 0 {
		textchange += 1
		if textchange > 3 { textchange = 0 }
		timer = 60
	}

	switch(textchange) {
		case(0): changex = lerp(changex, 1, textspeed); changey = lerp(changey, -1, textspeed); break;
		case(1): changex = lerp(changex, -1, textspeed); changey = lerp(changey, -1, textspeed); break;
		case(2): changex = lerp(changex, -1, textspeed); changey = lerp(changey, 1, textspeed); break;
		case(3): changex = lerp(changex, 1, textspeed); changey = lerp(changey, 1, textspeed); break;
	}

	// Hover color/distance lerp
	if mouseon = false {
		col = lerp(col, 0, 0.2 * (60 / global.maxfps))
		dist = lerp(dist, 0, 0.2 * (60 / global.maxfps))
	} else {
		col = lerp(col, 50, 0.2 * (60 / global.maxfps))
		dist = lerp(dist, 1, 0.2 * (60 / global.maxfps))
	}

	// Draw background rectangle
	backcolor = make_color_rgb((col / 5) / a, (col / 5) / a, (col / 5) / a)
	draw_set_color(backcolor)
	draw_rectangle(x, y, xx, yy, false)

	// Determine display text
	draw_set_color(c_white)
	draw_set_halign(fa_left)
	draw_set_valign(fa_center)

	var _display_text = ""
	if variable_struct_exists(self, "setting_label") {
		if variable_struct_exists(self, "use_loc") && use_loc {
			_display_text = loc(setting_label)
		} else {
			_display_text = setting_label
		}
	} else {
		_display_text = text
	}

	// Dynamic text scaling: fit text within ~70% of button width, capped
	var _text_w = string_width(_display_text)
	var _max_text_area = _btn_w * 0.68
	var _auto_scale = 1.0
	if _text_w > 0 {
		_auto_scale = min(0.55, _max_text_area / _text_w)
	}
	_auto_scale = max(_auto_scale, 0.25)
	var _sx = _auto_scale
	var _sy = _auto_scale

	// Draw text with depth layers
	if dist > 0.03 {
		for (textlayer = 0; textlayer < 5; textlayer++) {
			draw_set_color(make_color_rgb((100 + 32 * textlayer) / a, (100 + 32 * textlayer) / a, (100 + 32 * textlayer) / a))
			draw_text_transformed(
				(x + 8 + ((changex * dist) * textlayer)) + ox,
				(ytxt + _text_yoff + ((changey * dist) * textlayer)) + oy,
				_display_text, _sx, _sy, 0
			)
		}
	} else {
		draw_set_color(make_color_rgb(255 / a, 255 / a, 255 / a))
		draw_text_transformed(
			(x + 8 + ((changex * dist) * textlayer)) + ox,
			(ytxt + _text_yoff + ((changey * dist) * textlayer)) + oy,
			_display_text, _sx, _sy, 0
		)
	}

	// Draw state indicator (right side, inside button)
	if variable_struct_exists(self, "setting_type") {
		var _val = 0
		if variable_struct_exists(self, "setting_gvar") && setting_gvar != "" {
			_val = variable_global_get(setting_gvar)
		}

		// Position icon inside the button, near right edge
		var _icon_x = xx - 8 - 32
		var _icon_y = ytxt + _text_yoff - 16

		switch (setting_type) {
			case STYPE.TOGGLE:
				var _frame = (_val >= 1) ? 2 : 0
				draw_sprite(s_settingsindicators, _frame, _icon_x, _icon_y)
				break

			case STYPE.MULTI:
				var _max = variable_struct_exists(self, "setting_max") ? setting_max : 1
				var _option_text = ""
				var _idx = _val

				if variable_struct_exists(self, "setting_options") && is_array(setting_options) {
					if variable_struct_exists(self, "custom_cycle") && custom_cycle {
						_idx = 0
						if setting_gvar = "antialiasingsettings" {
							switch (_val) {
								case 0: _idx = 0; break;
								case 2: _idx = 1; break;
								case 4: _idx = 2; break;
								case 8: _idx = 3; break;
							}
						} else if setting_gvar = "maxfps" {
							switch (_val) {
								case 60:  _idx = 0; break;
								case 75:  _idx = 1; break;
								case 100: _idx = 2; break;
								case 120: _idx = 3; break;
								case 144: _idx = 4; break;
								case 150: _idx = 5; break;
								default:  _idx = 0; break;
							}
						} else {
							_idx = _val
						}
						if _idx >= 0 && _idx < array_length(setting_options) {
							_option_text = setting_options[_idx]
						}
					} else {
						if _val >= 0 && _val < array_length(setting_options) {
							_option_text = setting_options[_val]
						}
					}

					// Draw option text next to icon
					draw_set_halign(fa_right)
					draw_set_color(make_color_rgb(200 / a, 200 / a, 200 / a))
					draw_text_transformed(
						_icon_x - 4,
						ytxt + _text_yoff + oy,
						_option_text, _sx * 0.85, _sy * 0.85, 0
					)
				}

				// Draw state icon
				var _frame = 0
				var _icon_val = _val
				if variable_struct_exists(self, "custom_cycle") && custom_cycle && variable_struct_exists(self, "setting_options") {
					_icon_val = _idx
					_max = array_length(setting_options) - 1
				}
				if _icon_val = 0 { _frame = 0 }
				else if _icon_val >= _max { _frame = 2 }
				else { _frame = 1 }
				draw_sprite(s_settingsindicators, _frame, _icon_x, _icon_y)
				break

			case STYPE.CATEGORY:
				draw_set_halign(fa_right)
				draw_set_color(make_color_rgb(200 / a, 200 / a, 200 / a))
				draw_text_transformed(
					xx - 8,
					ytxt + _text_yoff + oy,
					">", _sx, _sy, 0
				)
				break

			case STYPE.ACTION:
				break
		}
	}

	// Draw border (thin lines)
	linecolor = make_color_rgb((dlineC_R / a), (dlineC_G / a), (dlineC_B - (5.1 * col)) / a)
	draw_set_color(linecolor)
	draw_line_width(x, y, xx, y, 2)   // Top
	draw_line_width(x, y, x, yy, 2)   // Left
	draw_line_width(xx, y, xx, yy, 2)  // Right
	draw_line_width(x, yy, xx, yy, 2)  // Bottom

	draw_set_halign(fa_left)
	draw_set_valign(fa_left)
	draw_set_color(c_white)

	// Controller support
	if mouseon = true {
		if gamepad_button_check_pressed(0, gp_face1) {
			event_perform(ev_mouse, ev_left_press)
		}
	}
}
