/// @function scr_drawsettingbutton()
/// @description Draws a code-based settings button with state indicator icons
function scr_drawsettingbutton() {
	var xx = (x + 5 * image_xscale)
	var yy = (y + 5 * image_yscale)
	var xtxt = (x + xx) / 2
	var ytxt = (y + yy) / 2
	draw_set_font(global.coolfont)
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

	// Draw label text
	draw_set_color(c_white)
	draw_set_halign(fa_left)
	draw_set_valign(fa_center)

	var _display_text = ""
	if variable_struct_exists(self, "setting_label") {
		_display_text = loc(setting_label)
	} else {
		_display_text = text
	}

	// Draw text with depth layers
	if dist > 0.03 {
		for (textlayer = 0; textlayer < 5; textlayer++) {
			draw_set_color(make_color_rgb((100 + 32 * textlayer) / a, (100 + 32 * textlayer) / a, (100 + 32 * textlayer) / a))
			draw_text_transformed(
				(x + 8 + ((changex * dist) * textlayer)) + ox,
				(ytxt + ((changey * dist) * textlayer)) + oy,
				_display_text, xscale * xMULTI, yscale * yMULTI, 0
			)
		}
	} else {
		draw_set_color(make_color_rgb(255 / a, 255 / a, 255 / a))
		draw_text_transformed(
			(x + 8 + ((changex * dist) * textlayer)) + ox,
			(ytxt + ((changey * dist) * textlayer)) + oy,
			_display_text, xscale * xMULTI, yscale * yMULTI, 0
		)
	}

	// Draw state indicator (right side)
	if variable_struct_exists(self, "setting_type") {
		var _val = 0
		if variable_struct_exists(self, "setting_gvar") && setting_gvar != "" {
			_val = variable_global_get(setting_gvar)
		}

		var _icon_x = xx - 24
		var _icon_y = ytxt - 16

		switch (setting_type) {
			case STYPE.TOGGLE:
				// Frame 0 = X (off), Frame 2 = checkmark (on)
				var _frame = (_val >= 1) ? 2 : 0
				draw_sprite(s_settingsindicators, _frame, _icon_x, _icon_y)
				break

			case STYPE.MULTI:
				// Show current option text + indicator icon
				var _max = variable_struct_exists(self, "setting_max") ? setting_max : 1
				var _option_text = ""
				var _idx = _val  // Default: index = value

				if variable_struct_exists(self, "setting_options") && is_array(setting_options) {
					// Map the actual value to the options array index
					if variable_struct_exists(self, "custom_cycle") && custom_cycle {
						// For custom cycle values (antialiasing: 0,2,4,8), use value-to-index mapping
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

					// Draw option text to the right
					draw_set_halign(fa_right)
					draw_set_color(make_color_rgb(200 / a, 200 / a, 200 / a))
					draw_text_transformed(
						_icon_x - 4,
						ytxt + oy,
						_option_text, xscale * xMULTI * 0.8, yscale * yMULTI * 0.8, 0
					)
				}

				// Draw state icon: 0=X, middle=~, max=checkmark
				var _frame = 0
				// Use the mapped index for custom cycle settings
				var _icon_val = _val
				if variable_struct_exists(self, "custom_cycle") && custom_cycle && variable_struct_exists(self, "setting_options") {
					_icon_val = _idx  // Use the index we computed above
					_max = array_length(setting_options) - 1
				}
				if _icon_val = 0 { _frame = 0 }
				else if _icon_val >= _max { _frame = 2 }
				else { _frame = 1 }
				draw_sprite(s_settingsindicators, _frame, _icon_x, _icon_y)
				break

			case STYPE.CATEGORY:
				// Draw > arrow
				draw_set_halign(fa_right)
				draw_set_color(make_color_rgb(200 / a, 200 / a, 200 / a))
				draw_text_transformed(
					xx - 8,
					ytxt + oy,
					">", xscale * xMULTI, yscale * yMULTI, 0
				)
				break

			case STYPE.ACTION:
				// No indicator needed
				break
		}
	}

	// Draw border
	linecolor = make_color_rgb((dlineC_R / a), (dlineC_G / a), (dlineC_B - (5.1 * col)) / a)
	draw_set_color(linecolor)
	draw_line_width(x, y, xx, y, width)   // Top
	draw_line_width(x, y, x, yy, width)   // Left
	draw_line_width(xx, y, xx, yy, width)  // Right
	draw_line_width(x, yy, xx, yy, width)  // Bottom

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
