if filtered_out = 1 { exit; }

// Grid tile layout: 2 columns
var _tile_w = 390
var _tile_h = 130
var _col_x = base_x
var _row_y = base_y - global.workshopchallenge_scroll

x = lerp(x, _col_x, 0.1 * (60 / global.maxfps))
y = lerp(y, _row_y, 0.1 * (60 / global.maxfps))

// Clip to visible area
if y < 280 { exit; }
if y > 580 { exit; }

var _x1 = x
var _y1 = y
var _x2 = x + _tile_w
var _y2 = y + _tile_h

// Background
var border_col = c_white
if selected = 1 { border_col = c_lime }
draw_rectangle_color(_x1,_y1,_x2,_y2,c_black,$1d1d1d,c_black,$1d1d1d,false)
draw_rectangle_color(_x1,_y1,_x2,_y2,border_col,border_col,border_col,border_col,true)

// Thumbnail area (left side)
var _thumb_x = _x1 + 5
var _thumb_y = _y1 + 5
var _thumb_w = 120
var _thumb_h = _tile_h - 10

if (thumb_spr != -1) {
	var _sw = sprite_get_width(thumb_spr)
	var _sh = sprite_get_height(thumb_spr)
	var _scale = min(_thumb_w / _sw, _thumb_h / _sh)
	var _dx = _thumb_x + (_thumb_w - _sw * _scale) / 2
	var _dy = _thumb_y + (_thumb_h - _sh * _scale) / 2
	draw_sprite_ext(thumb_spr, 0, _dx, _dy, _scale, _scale, 0, c_white, 1)
} else {
	// Placeholder
	draw_set_color($1a1a2e)
	draw_rectangle(_thumb_x, _thumb_y, _thumb_x + _thumb_w, _thumb_y + _thumb_h, false)
	draw_set_color($444444)
	draw_rectangle(_thumb_x, _thumb_y, _thumb_x + _thumb_w, _thumb_y + _thumb_h, true)
	draw_set_color(c_gray)
	draw_set_font(global.deathfont)
	draw_set_halign(fa_center)
	draw_set_valign(fa_middle)
	draw_text(_thumb_x + _thumb_w/2, _thumb_y + _thumb_h/2, "No\nPreview")
	draw_set_valign(fa_top)
	draw_set_halign(fa_left)
}

// Text area (right side)
var _text_x = _x1 + _thumb_w + 15
var _text_y = _y1 + 8

draw_set_color(c_white)
draw_set_font(global.deathfont)
draw_set_halign(fa_left)

// Selection indicator
if selected = 1 {
	draw_set_color(c_lime)
	draw_text(_text_x, _text_y, "[" + string(selected_order) + "]")
	draw_set_color(c_white)
	draw_text(_text_x + 30, _text_y, string_copy(string(mTitle), 1, 24))
} else {
	draw_text_ext(_text_x, _text_y, string(mTitle), 18, _tile_w - _thumb_w - 25)
}

// Diamond time
draw_text(_text_x, _text_y + 38, "Diamond: " + string(diamond_time) + "s")

// Difficulty icons
var diff_disp = difficulty
if diff_disp < 0 { diff_disp = 0 }
if diff_disp > 6 { diff_disp = 6 }

var diffspr = noone
var sprnum = 0
draw_set_color(c_white)
for(var i=0;i<diff_disp;i++) {
	switch(diff_disp) {
	case(1): diffspr = s_playerwhite break;
	case(2): diffspr = s_playerblue break;
	case(3): diffspr = s_playergreen break;
	case(4): diffspr = s_playeryellow break;
	case(5): diffspr = s_playerred break;
	case(6):
		diffspr = s_playerdead
		draw_set_color(c_red)
		sprnum = 5
	break;
	}
	draw_sprite_ext(diffspr,sprnum,_text_x + (i*22),_text_y + 72,0.6,0.6,0,c_white,1)
}
if diff_disp = 0 {
	draw_set_color(c_gray)
	draw_text(_text_x,_text_y + 70,"Not rated")
}

draw_set_halign(fa_left)
draw_set_color(c_white)
