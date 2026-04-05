/// @description Draw custom levels browser overlay (Draw GUI End)

// Dark overlay background
draw_set_alpha(0.92 * overlay_alpha)
draw_rectangle_color(0, 0, 1024, 768, c_black, c_black, c_black, c_black, false)
draw_set_alpha(overlay_alpha)

// Content panel background - pure black with white border (game style)
var _panel_x = grid_margin_x - 20
var _panel_y = 40
var _panel_w = 1024 - 2 * _panel_x
var _panel_h = 768 - _panel_y - 20
draw_set_color(c_black)
draw_rectangle(_panel_x, _panel_y, _panel_x + _panel_w, _panel_y + _panel_h, false)
draw_set_color(c_white)
draw_rectangle(_panel_x, _panel_y, _panel_x + _panel_w, _panel_y + _panel_h, true)

draw_set_font(global.deathfont)
draw_set_halign(fa_center)
draw_set_valign(fa_top)
draw_set_color(c_white)

// Header title
draw_text(512, 52, loc("PLAY_CUSTOM_LEVELS"))

// Close button (X) top-right - white, blue on hover
var _xbtn_x = _panel_x + _panel_w - 18
var _xbtn_y = _panel_y + 8
var _mx = device_mouse_x_to_gui(0)
var _my = device_mouse_y_to_gui(0)
var _x_hover = (_mx >= _xbtn_x - 14 && _mx <= _xbtn_x + 14 && _my >= _xbtn_y - 4 && _my <= _xbtn_y + 24)
draw_set_halign(fa_center)
draw_set_color(_x_hover ? c_red : c_white)
draw_text(_xbtn_x, _xbtn_y, "X")
draw_set_color(c_white)

// Tab buttons - game style: black fill, white border, blue highlight
var _tab_y = 80
var _tab_h = 28
var _tab1_x = 512 - 160
var _tab2_x = 512 + 10
var _tab_w = 150

// Tab 1: Subscribed
var _tab1_hover = (_mx >= _tab1_x && _mx <= _tab1_x + _tab_w && _my >= _tab_y && _my <= _tab_y + _tab_h)
draw_set_color(c_black)
draw_rectangle(_tab1_x, _tab_y, _tab1_x + _tab_w, _tab_y + _tab_h, false)
if tab = 0 {
	draw_set_color(c_white)
	draw_rectangle(_tab1_x, _tab_y, _tab1_x + _tab_w, _tab_y + _tab_h, true)
	draw_set_color(c_white)
} else {
	draw_set_color(_tab1_hover ? c_white : c_dkgray)
	draw_rectangle(_tab1_x, _tab_y, _tab1_x + _tab_w, _tab_y + _tab_h, true)
	draw_set_color(_tab1_hover ? c_white : c_gray)
}
draw_set_halign(fa_center)
draw_text(_tab1_x + _tab_w / 2, _tab_y + 4, loc("SUBSCRIBED_LEVELS"))

// Tab 2: Browse Workshop
var _tab2_hover = (_mx >= _tab2_x && _mx <= _tab2_x + _tab_w && _my >= _tab_y && _my <= _tab_y + _tab_h)
draw_set_color(c_black)
draw_rectangle(_tab2_x, _tab_y, _tab2_x + _tab_w, _tab_y + _tab_h, false)
if tab = 1 {
	draw_set_color(c_white)
	draw_rectangle(_tab2_x, _tab_y, _tab2_x + _tab_w, _tab_y + _tab_h, true)
	draw_set_color(c_white)
} else {
	draw_set_color(_tab2_hover ? c_white : c_dkgray)
	draw_rectangle(_tab2_x, _tab_y, _tab2_x + _tab_w, _tab_y + _tab_h, true)
	draw_set_color(_tab2_hover ? c_white : c_gray)
}
draw_set_halign(fa_center)
draw_text(_tab2_x + _tab_w / 2, _tab_y + 4, loc("BROWSE_WORKSHOP"))

// Search bar (browse tab only)
var _actual_grid_top = grid_top_y
if tab = 1 {
	var _search_x = grid_margin_x
	var _search_y = 116
	var _search_w = 1024 - 2 * grid_margin_x
	var _search_h = 24

	draw_set_color(c_black)
	draw_rectangle(_search_x, _search_y, _search_x + _search_w, _search_y + _search_h, false)
	draw_set_color(editing_search ? c_white : c_dkgray)
	draw_rectangle(_search_x, _search_y, _search_x + _search_w, _search_y + _search_h, true)

	draw_set_halign(fa_left)
	if browse_search_text = "" && !editing_search {
		draw_set_color(c_gray)
		draw_text(_search_x + 8, _search_y + 3, loc("SEARCH_WORKSHOP"))
	} else {
		draw_set_color(c_white)
		var _display_text = browse_search_text
		if editing_search && ((current_time div 500) mod 2 = 0) {
			_display_text += "|"
		}
		draw_text(_search_x + 8, _search_y + 3, _display_text)
	}

	_actual_grid_top = 148
}

// Determine active level array
var _active_levels = (tab = 0) ? levels : browse_levels
var _active_count = (tab = 0) ? levels_count : browse_count

// Scissor clip the grid area
gpu_set_scissor(grid_margin_x - 5, _actual_grid_top, 1024 - 2 * grid_margin_x + 10, grid_bottom_y - _actual_grid_top)

// Draw loading state for browse tab
if tab = 1 && browse_state = "loading" {
	draw_set_halign(fa_center)
	draw_set_valign(fa_middle)
	draw_set_color(c_white)
	var _dots = ""
	repeat((current_time div 333) mod 4) _dots += "."
	draw_text(512, (_actual_grid_top + grid_bottom_y) / 2, "LOADING" + _dots)
	draw_set_valign(fa_top)
}

// Lazy thumbnail loading: load up to 2 thumbnails per frame for visible tiles
var _thumbs_loaded_this_frame = 0

// Draw tiles in 3-column grid
hover_index = -1
for (var i = 0; i < _active_count; i++) {
	var _col = i mod grid_cols
	var _row = i div grid_cols
	var _tx = grid_margin_x + _col * (tile_w + grid_gap)
	var _ty = _actual_grid_top + _row * (tile_h + grid_gap) - scroll

	// Skip off-screen tiles
	if (_ty + tile_h < _actual_grid_top) continue
	if (_ty > grid_bottom_y) continue

	var _lvl = _active_levels[i]
	var _is_hover = (_mx >= _tx && _mx <= _tx + tile_w && _my >= max(_actual_grid_top, _ty) && _my <= min(grid_bottom_y, _ty + tile_h))
	if _is_hover { hover_index = i }

	// Lazy load thumbnail if not yet checked and tile is visible
	if !_lvl.thumb_checked && _lvl.path != "" && _thumbs_loaded_this_frame < 2 {
		_lvl.thumb_checked = true
		if file_exists(_lvl.path + "thumb.jpg") {
			_lvl.thumb_spr = sprite_add(_lvl.path + "thumb.jpg", 0, false, false, 0, 0)
		} else if file_exists(_lvl.path + "thumb.png") {
			_lvl.thumb_spr = sprite_add(_lvl.path + "thumb.png", 0, false, false, 0, 0)
		}
		_thumbs_loaded_this_frame++
	}

	// Tile background - black fill, white/highlight border (game style)
	draw_set_color(c_black)
	draw_rectangle(_tx, _ty, _tx + tile_w, _ty + tile_h, false)
	var _border_col = _is_hover ? c_white : c_dkgray
	draw_set_color(_border_col)
	draw_rectangle(_tx, _ty, _tx + tile_w, _ty + tile_h, true)

	// Thumbnail area - 4:3 aspect ratio box
	var _thumb_area_w = tile_w - 4
	var _thumb_area_h = floor(_thumb_area_w * 3 / 4) // 4:3 = 214px wide, ~160px tall
	if _thumb_area_h > tile_h - 50 { _thumb_area_h = tile_h - 50 } // leave room for text

	if _lvl.thumb_spr != -1 && sprite_exists(_lvl.thumb_spr) {
		var _sw = sprite_get_width(_lvl.thumb_spr)
		var _sh = sprite_get_height(_lvl.thumb_spr)
		// Scale to fill 4:3 box
		var _scale = max(_thumb_area_w / _sw, _thumb_area_h / _sh)
		var _draw_w = _sw * _scale
		var _draw_h = _sh * _scale
		// Center and clip via the existing scissor
		var _dx = _tx + 2 + (_thumb_area_w - _draw_w) / 2
		var _dy = _ty + 2 + (_thumb_area_h - _draw_h) / 2
		draw_sprite_ext(_lvl.thumb_spr, 0, _dx, _dy, _scale, _scale, 0, c_white, 1)
	} else {
		// "No Preview" placeholder
		draw_set_color($0a0a0a)
		draw_rectangle(_tx + 2, _ty + 2, _tx + tile_w - 2, _ty + 2 + _thumb_area_h, false)
		draw_set_color(c_dkgray)
		draw_rectangle(_tx + 2, _ty + 2, _tx + tile_w - 2, _ty + 2 + _thumb_area_h, true)
		draw_set_color(c_gray)
		draw_set_halign(fa_center)
		draw_set_valign(fa_middle)
		draw_text(_tx + tile_w / 2, _ty + 2 + _thumb_area_h / 2, "No\nPreview")
		draw_set_valign(fa_top)
	}

	// Download overlay for browse tab items
	if tab = 1 && _lvl.download_state != "installed" {
		draw_set_alpha(0.7)
		draw_set_color(c_black)
		draw_rectangle(_tx + 2, _ty + 2, _tx + tile_w - 2, _ty + 2 + _thumb_area_h, false)
		draw_set_alpha(overlay_alpha)

		draw_set_halign(fa_center)
		draw_set_valign(fa_middle)
		if _lvl.download_state = "downloading" || _lvl.download_state = "pending" {
			draw_set_color(c_lime)
			draw_text(_tx + tile_w / 2, _ty + 2 + _thumb_area_h / 2, loc("DOWNLOADING_LEVEL"))
		} else {
			draw_set_color(_is_hover ? c_white : c_ltgray)
			draw_text(_tx + tile_w / 2, _ty + 2 + _thumb_area_h / 2, loc("SUBSCRIBE"))
		}
		draw_set_valign(fa_top)
	}

	// Download state indicator for subscribed tab
	if tab = 0 && (_lvl.download_state = "downloading" || _lvl.download_state = "pending") {
		draw_set_alpha(0.7)
		draw_set_color(c_black)
		draw_rectangle(_tx + 2, _ty + 2, _tx + tile_w - 2, _ty + 2 + _thumb_area_h, false)
		draw_set_alpha(overlay_alpha)
		draw_set_halign(fa_center)
		draw_set_valign(fa_middle)
		draw_set_color(c_lime)
		draw_text(_tx + tile_w / 2, _ty + 2 + _thumb_area_h / 2, loc("DOWNLOADING_LEVEL"))
		draw_set_valign(fa_top)
	}

	// Text area below thumbnail
	var _text_y = _ty + 2 + _thumb_area_h + 4
	draw_set_halign(fa_left)
	draw_set_color(c_white)

	// Title (clipped to tile width)
	draw_text_ext(_tx + 6, _text_y, string(_lvl.title), -1, tile_w - 12)

	// Author name
	draw_set_color(c_gray)
	draw_text_ext(_tx + 6, _text_y + 18, string(_lvl.owner_name), -1, tile_w - 80)

	// Like/Dislike with sprite icons using scribble
	draw_set_halign(fa_right)
	draw_set_color(c_white)
	draw_text_scribble(_tx + tile_w - 6, _text_y + 18, "[s_likeemote]" + string(_lvl.likes) + " [s_dislikeemote]" + string(_lvl.dislikes))
	draw_set_halign(fa_left)

	// Difficulty icons
	var _diff = _lvl.difficulty
	if _diff > 0 && _diff <= 6 {
		var _diffspr = noone
		var _sprnum = 0
		switch(_diff) {
			case 1: _diffspr = s_playerwhite; break
			case 2: _diffspr = s_playerblue; break
			case 3: _diffspr = s_playergreen; break
			case 4: _diffspr = s_playeryellow; break
			case 5: _diffspr = s_playerred; break
			case 6: _diffspr = s_playerdead; _sprnum = 5; break
		}
		for (var d = 0; d < _diff; d++) {
			draw_sprite_ext(_diffspr, _sprnum, _tx + 6 + (d * 18), _text_y + 36, 0.5, 0.5, 0, c_white, 1)
		}
	} else {
		draw_set_color(c_gray)
		draw_text_transformed(_tx + 6, _text_y + 38, loc("NOT_RATED_YET"), 0.6, 0.6, 0)
	}

	// Medal display
	if tab = 0 {
		var _dmedal = _lvl.medal_required
		var _gmedal = _dmedal * 1.1
		var _smedal = _gmedal * 1.2
		var _bmedal = _smedal * 1.3
		var _best = _lvl.medal_time

		if _best < _bmedal {
			var _medal_spr = 0
			if _best < _bmedal { _medal_spr = 0 }
			if _best < _smedal { _medal_spr = 1 }
			if _best < _gmedal { _medal_spr = 2 }
			if _best < _dmedal { _medal_spr = 3 }
			draw_sprite_ext(s_medals, _medal_spr, _tx + tile_w - 24, _text_y + 44, 0.05, 0.05, 0, c_white, 1)
		}
	}

	// Featured star
	if _lvl.featured {
		draw_sprite(s_featuredstar, 0, _tx + 4, _ty + 4)
	}

	// Banned overlay
	if _lvl.banned {
		draw_set_alpha(0.8)
		draw_set_color(c_black)
		draw_rectangle(_tx, _ty, _tx + tile_w, _ty + tile_h, false)
		draw_set_alpha(overlay_alpha)
		draw_set_color(c_red)
		draw_set_halign(fa_center)
		draw_set_valign(fa_middle)
		draw_text(_tx + tile_w / 2, _ty + tile_h / 2, loc("THIS_MAP_IS_BANNED_FROM_WORKSHOP"))
		draw_set_valign(fa_top)
	}

	draw_set_color(c_white)
}

// "Load More" button for browse tab
if tab = 1 && browse_state = "loaded" && browse_count < browse_total {
	var _lm_row = ceil(real(browse_count) / grid_cols)
	var _lm_y = _actual_grid_top + _lm_row * (tile_h + grid_gap) - scroll
	if _lm_y > _actual_grid_top && _lm_y < grid_bottom_y {
		var _lm_hover = (_mx >= grid_margin_x && _mx <= 1024 - grid_margin_x && _my >= _lm_y && _my < _lm_y + 40)
		draw_set_color(c_black)
		draw_rectangle(grid_margin_x, _lm_y, 1024 - grid_margin_x, _lm_y + 40, false)
		draw_set_color(_lm_hover ? c_white : c_dkgray)
		draw_rectangle(grid_margin_x, _lm_y, 1024 - grid_margin_x, _lm_y + 40, true)
		draw_set_halign(fa_center)
		draw_set_valign(fa_middle)
		draw_set_color(_lm_hover ? c_white : c_gray)
		draw_text(512, _lm_y + 20, loc("LOAD_MORE"))
		draw_set_valign(fa_top)
	}
}

gpu_set_scissor(-1, -1, -1, -1)

// Scroll bar - white on dark
if scroll_max > 0 {
	var _bar_area_h = grid_bottom_y - _actual_grid_top
	var _bar_h = max(30, _bar_area_h * (_bar_area_h / (_bar_area_h + scroll_max)))
	var _bar_y = _actual_grid_top + (scroll / scroll_max) * (_bar_area_h - _bar_h)
	var _bar_x = 1024 - grid_margin_x + 6

	draw_set_color(c_dkgray)
	draw_rectangle(_bar_x, _actual_grid_top, _bar_x + 4, grid_bottom_y, false)
	draw_set_color(c_white)
	draw_rectangle(_bar_x, _bar_y, _bar_x + 4, _bar_y + _bar_h, false)
}

// Bottom status text
draw_set_halign(fa_left)
draw_set_color(c_gray)
if tab = 0 {
	draw_text(grid_margin_x, grid_bottom_y + 8, string(levels_count) + " levels")
} else {
	if browse_state = "loaded" {
		draw_text(grid_margin_x, grid_bottom_y + 8, string(browse_count) + " / " + string(browse_total) + " results")
	}
}

// Reset draw state
draw_set_alpha(1)
draw_set_color(c_white)
draw_set_halign(fa_left)
draw_set_valign(fa_top)
