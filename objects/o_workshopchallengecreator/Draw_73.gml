// The level cards (o_workshoplevelselectbutton) draw before this, at a lower
// depth, and scroll freely. These opaque bands hide whatever spills past the list.
var _filter = gpu_get_texfilter()
gpu_set_texfilter(true) // keep scaled text and faces smooth whatever the player's texture-filter setting is
draw_set_alpha(1)
draw_set_color(WC_UI_BG)
draw_rectangle(0, 0, 1024, L.list[1], false)
draw_rectangle(0, L.list[3], 1024, 768, false)

var _blink = (((current_time div 500) mod 2) == 0)

// ---- Header -------------------------------------------------------------
draw_set_font(fnt_mainmenu)
draw_set_halign(fa_left)
draw_set_valign(fa_top)
draw_set_color(c_white)
draw_text_transformed(24, 4, "Create Workshop Challenge", 0.6, 0.6, 0)
scr_workshopchallenge_ui_text(26, 52, "Pick levels, put them in order, beat the challenge yourself, then upload it.", 0.62, WC_UI_DIM)
draw_set_color(WC_UI_LINE)
draw_line(0, 77, 1024, 77)
draw_set_color(WC_UI_GOOD)
draw_rectangle(24, 76, 96, 78, false)

var _cy_close = (L.close[1] + L.close[3]) / 2
scr_workshopchallenge_ui_box(L.close, merge_color(WC_UI_PANEL, WC_UI_BAD, 0.08 + 0.25 * hv.close), merge_color(WC_UI_LINE, WC_UI_BAD, hv.close), 7, 1)
scr_workshopchallenge_ui_cross(L.close[0] + 24, _cy_close, 5, merge_color(WC_UI_DIM, c_white, hv.close), 2)
scr_workshopchallenge_ui_text(L.close[0] + 42, _cy_close, "Close", 0.8, merge_color(WC_UI_DIM, c_white, hv.close), fa_left, fa_middle)

// ---- Library: tabs + search --------------------------------------------
var _tab_rects = [L.tab_sub, L.tab_my]
var _tab_hv = [hv.tab0, hv.tab1]
var _tab_text = ["Subscribed (" + string(total_count) + ")", (unloaded_count > 0) ? "My Levels" : "My Levels (" + string(owned_count) + ")"]
for (var t = 0; t < 2; t++) {
	var _active = (filter_mode == t)
	var _r = _tab_rects[t]
	scr_workshopchallenge_ui_box(_r,
		_active ? WC_UI_PANEL_HI : merge_color(WC_UI_PANEL, WC_UI_PANEL_HI, _tab_hv[t] * 0.7),
		_active ? WC_UI_GOOD : merge_color(WC_UI_LINE, c_white, _tab_hv[t] * 0.45), 7, _active ? 2 : 1)
	scr_workshopchallenge_ui_text((_r[0] + _r[2]) / 2, (_r[1] + _r[3]) / 2, _tab_text[t], 0.72,
		_active ? c_white : merge_color(WC_UI_DIM, c_white, _tab_hv[t]), fa_center, fa_middle)
}

var _sy = (L.search[1] + L.search[3]) / 2
var _searching = (editing == 2)
scr_workshopchallenge_ui_box(L.search, WC_UI_PANEL, _searching ? WC_UI_GOOD : merge_color(WC_UI_LINE, c_white, hv.search * 0.4), 7, _searching ? 2 : 1)
scr_workshopchallenge_ui_search_icon(L.search[0] + 20, _sy, _searching ? WC_UI_GOOD : WC_UI_DIM)
draw_set_font(global.deathfont)
var _search_w = L.search[2] - L.search[0] - 82
if search != "" || _searching {
	var _stext = scr_workshopchallenge_ui_tail(search, _search_w, 0.75)
	scr_workshopchallenge_ui_text(L.search[0] + 40, _sy, _stext, 0.75, c_white, fa_left, fa_middle)
	if _searching && _blink {
		var _sx = L.search[0] + 41 + string_width(_stext) * 0.75
		draw_set_color(WC_UI_GOOD)
		draw_line_width(_sx, _sy - 9, _sx, _sy + 9, 2)
	}
} else {
	scr_workshopchallenge_ui_text(L.search[0] + 40, _sy, "Search levels...", 0.75, WC_UI_DIM, fa_left, fa_middle)
}
if search != "" {
	var _hx = (hot == "searchclear")
	scr_workshopchallenge_ui_cross((L.search_clear[0] + L.search_clear[2]) / 2, _sy, 4, _hx ? c_white : WC_UI_DIM, 2)
}

// ---- Library: count + select all ---------------------------------------
var _base_count = (filter_mode == 1) ? owned_count : total_count
var _info = string(_base_count) + ((_base_count == 1) ? " level" : " levels")
if visible_count != _base_count { _info = string(visible_count) + " of " + string(_base_count) + " levels" }
scr_workshopchallenge_ui_text(26, L.info_y, _info, 0.64, WC_UI_DIM, fa_left, fa_middle)
if visible_count > 0 {
	var _sel_text = all_shown_picked ? "Deselect all" : "Select all"
	var _sel_col = merge_color(WC_UI_GOOD, c_white, hv.selall)
	scr_workshopchallenge_ui_text(L.select_all[2], L.info_y, _sel_text, 0.66, _sel_col, fa_right, fa_middle)
	if hv.selall > 0.3 {
		var _sel_w = string_width(_sel_text) * 0.66
		draw_set_color(_sel_col)
		draw_line(L.select_all[2] - _sel_w, L.info_y + 11, L.select_all[2], L.info_y + 11)
	}
}

// ---- Library: empty states ---------------------------------------------
if visible_count = 0 {
	var _ex = (L.list[0] + L.list[2]) / 2
	var _ey = (L.list[1] + L.list[3]) / 2 - 16
	var _head = "Loading levels..."
	var _sub = ""
	if total_count = 0 {
		_head = "No subscribed Workshop levels yet"
		_sub = "Subscribe to levels on the Steam Workshop and they will show up here."
	} else if search != "" {
		_head = "No levels match \"" + search + "\""
		_sub = "Try a different search."
	} else if filter_mode = 1 {
		if unloaded_count > 0 {
			_head = "Checking your levels..."
		} else {
			_head = "None of your subscribed levels are yours"
			_sub = "Levels you publish from the level editor show up here."
		}
	}
	scr_workshopchallenge_ui_text(_ex, _ey, _head, 0.85, c_white, fa_center, fa_middle)
	if _sub != "" { scr_workshopchallenge_ui_text(_ex, _ey + 30, _sub, 0.62, WC_UI_DIM, fa_center, fa_middle) }
}

// ---- Library: scrollbar --------------------------------------------------
if sb_thumb_h > 0 {
	var _lit = (hot == "scrollbar" || sb_drag)
	draw_set_color(WC_UI_PANEL)
	draw_roundrect_ext(L.sb[0], L.sb[1], L.sb[2], L.sb[3], 4, 4, false)
	draw_set_color(_lit ? WC_UI_GOOD : WC_UI_LINE)
	draw_roundrect_ext(L.sb[0], sb_thumb_y, L.sb[2], sb_thumb_y + sb_thumb_h, 4, 4, false)
}

// ---- Challenge panel: title --------------------------------------------
scr_workshopchallenge_ui_text(L.title_box[0], 101, "CHALLENGE TITLE", 0.6, WC_UI_DIM, fa_left, fa_middle)
var _typing = (editing == 1)
var _ty = (L.title_box[1] + L.title_box[3]) / 2
scr_workshopchallenge_ui_box(L.title_box, WC_UI_PANEL, _typing ? WC_UI_GOOD : merge_color(WC_UI_LINE, c_white, hv.title * 0.4), 7, _typing ? 2 : 1)
draw_set_font(global.deathfont)
var _title_w = L.title_box[2] - L.title_box[0] - 80
if title != "" || _typing {
	var _ttext = scr_workshopchallenge_ui_tail(title, _title_w, 0.8)
	scr_workshopchallenge_ui_text(L.title_box[0] + 14, _ty, _ttext, 0.8, c_white, fa_left, fa_middle)
	if _typing && _blink {
		var _tx = L.title_box[0] + 15 + string_width(_ttext) * 0.8
		draw_set_color(WC_UI_GOOD)
		draw_line_width(_tx, _ty - 11, _tx, _ty + 11, 2)
	}
	scr_workshopchallenge_ui_text(L.title_box[2] - 12, _ty, string(string_length(title)) + "/40", 0.55, WC_UI_DIM, fa_right, fa_middle)
} else {
	scr_workshopchallenge_ui_text(L.title_box[0] + 14, _ty, "Name your challenge", 0.8, WC_UI_DIM, fa_left, fa_middle)
}

// ---- Challenge panel: sequence -----------------------------------------
var _n = array_length(selection)
var _seq_x2 = L.seq[2] - 12
scr_workshopchallenge_ui_text(L.side[0], 173, "LEVELS IN ORDER" + ((_n > 0) ? " (" + string(_n) + ")" : ""), 0.6, WC_UI_DIM, fa_left, fa_middle)
if _n > 0 {
	scr_workshopchallenge_ui_text(L.seq_clear[2], 173, "Clear all", 0.62, merge_color(WC_UI_DIM, WC_UI_BAD, hv.clear), fa_right, fa_middle)
}

if _n = 0 {
	scr_workshopchallenge_ui_box(L.seq, WC_UI_WELL, WC_UI_LINE, 8, 1)
	var _qx = (L.seq[0] + L.seq[2]) / 2
	var _qy = (L.seq[1] + L.seq[3]) / 2
	scr_workshopchallenge_ui_text(_qx, _qy - 24, "No levels yet", 0.85, c_white, fa_center, fa_middle)
	scr_workshopchallenge_ui_text(_qx, _qy + 4, "Click levels on the left to add them.", 0.62, WC_UI_DIM, fa_center, fa_middle)
	scr_workshopchallenge_ui_text(_qx, _qy + 24, "They play in the order you add them.", 0.62, WC_UI_DIM, fa_center, fa_middle)
}

draw_set_font(global.deathfont)
for (var r = 0; r < L.seq_rows; r++) {
	var _idx = seq_first + r
	if _idx >= _n { break }
	var _b = selection[_idx]
	var _ry = L.seq[1] + r * L.seq_pitch
	var _rc = _ry + L.seq_row_h / 2
	var _row_hot = (hot == "seq" && hot_i == _idx)
	scr_workshopchallenge_ui_box([L.seq[0], _ry, _seq_x2, _ry + L.seq_row_h], _row_hot ? WC_UI_PANEL_HI : WC_UI_PANEL, _row_hot ? merge_color(WC_UI_LINE, c_white, 0.35) : WC_UI_LINE, 6, 1)

	// Play order badge
	draw_set_color(WC_UI_GOOD)
	draw_circle(L.seq[0] + 18, _rc, 11, false)
	scr_workshopchallenge_ui_text(L.seq[0] + 18, _rc, _idx + 1, (_idx + 1 > 99) ? 0.48 : 0.62, WC_UI_BG, fa_center, fa_middle)

	var _name = scr_workshopchallenge_ui_wrap(_b.mTitle, (_seq_x2 - 94) - (L.seq[0] + 38), 0.72, 1)
	scr_workshopchallenge_ui_text(L.seq[0] + 38, _rc, (array_length(_name) > 0) ? _name[0] : "", 0.72, c_white, fa_left, fa_middle)

	// Move up / move down / remove
	for (var j = 0; j < 3; j++) {
		var _bx = _seq_x2 - 86 + j * 28
		var _on = (_row_hot && hot_j == j)
		var _off = (j == 0 && _idx == 0) || (j == 1 && _idx == _n - 1)
		if _on && !_off {
			scr_workshopchallenge_ui_box([_bx, _rc - 11, _bx + 24, _rc + 11], (j == 2) ? merge_color(WC_UI_PANEL, WC_UI_BAD, 0.35) : WC_UI_LINE, -1, 5)
		}
		var _ic = _off ? WC_UI_LINE : (_on ? c_white : WC_UI_DIM)
		if j = 2 { scr_workshopchallenge_ui_cross(_bx + 12, _rc, 4, (_on && !_off) ? WC_UI_BAD : _ic, 2) }
		else { scr_workshopchallenge_ui_arrow(_bx + 12, _rc, (j == 0), _ic) }
	}
}

if _n > L.seq_rows {
	var _st = L.seq_sb[3] - L.seq_sb[1]
	var _sth = max(30, _st * (L.seq_rows / _n))
	var _sty = L.seq_sb[1] + (seq_first / (_n - L.seq_rows)) * (_st - _sth)
	draw_set_color(WC_UI_PANEL)
	draw_roundrect_ext(L.seq_sb[0], L.seq_sb[1], L.seq_sb[2], L.seq_sb[3], 4, 4, false)
	draw_set_color(WC_UI_LINE)
	draw_roundrect_ext(L.seq_sb[0], _sty, L.seq_sb[2], _sty + _sth, 4, 4, false)
}

// ---- Challenge panel: totals -------------------------------------------
scr_workshopchallenge_ui_box(L.stats, WC_UI_PANEL, WC_UI_LINE, 8, 1)
var _r1 = L.stats[1] + 17
var _r2 = L.stats[1] + 49
var _rx = L.stats[2] - 12
scr_workshopchallenge_ui_text(L.stats[0] + 12, _r1, "Total diamond time", 0.62, WC_UI_DIM, fa_left, fa_middle)
scr_workshopchallenge_ui_text(L.stats[0] + 12, _r2, "Average difficulty", 0.62, WC_UI_DIM, fa_left, fa_middle)
draw_set_font(global.deathfont)
if _n > 0 {
	var _dt = scr_workshopchallenge_ui_time(diamond_sum)
	scr_workshopchallenge_ui_text(_rx, _r1, _dt, 0.8, c_white, fa_right, fa_middle)
	scr_workshopchallenge_ui_diamond(_rx - string_width(_dt) * 0.8 - 12, _r1, 6, WC_UI_DIAMOND)

	var _dn = scr_workshopchallenge_ui_difficulty_name(difficulty_avg)
	var _dn_w = string_width(_dn) * 0.62
	scr_workshopchallenge_ui_text(_rx, _r2, _dn, 0.62, c_white, fa_right, fa_middle)
	var _faces = clamp(round(difficulty_avg), 0, 6)
	scr_workshopchallenge_ui_difficulty(_rx - _dn_w - 8 - _faces * 17, _r2, _faces, 0.55, 17)
} else {
	scr_workshopchallenge_ui_text(_rx, _r1, "-", 0.8, WC_UI_DIM, fa_right, fa_middle)
	scr_workshopchallenge_ui_text(_rx, _r2, "-", 0.8, WC_UI_DIM, fa_right, fa_middle)
}

// ---- Challenge panel: what is still missing ----------------------------
var _chips = [
	{ label: "Title", ok: ok_title },
	{ label: "Levels", ok: ok_levels }
]
if !ok_cheats { array_push(_chips, { label: "Cheats off", ok: false, bad: true }) }
array_push(_chips, { label: "Beaten", ok: ok_beaten, soon: (ok_title && ok_levels && ok_cheats) })

draw_set_font(global.deathfont)
var _cx = L.side[0]
for (var c = 0; c < array_length(_chips); c++) {
	var _chip = _chips[c]
	var _cw = string_width(_chip.label) * 0.58 + 34
	var _border = WC_UI_LINE
	if _chip.ok { _border = WC_UI_GOOD }
	else if variable_struct_exists(_chip, "bad") { _border = WC_UI_BAD }
	else if variable_struct_exists(_chip, "soon") && _chip.soon { _border = WC_UI_WARN }
	scr_workshopchallenge_ui_box([_cx, L.chips_y, _cx + _cw, L.chips_y + 22], WC_UI_PANEL, _border, 11, 1)
	if _chip.ok {
		scr_workshopchallenge_ui_check(_cx + 13, L.chips_y + 11, WC_UI_GOOD, 0.8)
	} else {
		draw_set_color(WC_UI_DIM)
		draw_circle(_cx + 13, L.chips_y + 11, 4, true)
	}
	scr_workshopchallenge_ui_text(_cx + 23, L.chips_y + 11, _chip.label, 0.58, _chip.ok ? c_white : WC_UI_DIM, fa_left, fa_middle)
	_cx += _cw + 6
}

// ---- Challenge panel: actions ------------------------------------------
var _can_play = (ok_title && ok_levels)
scr_workshopchallenge_ui_button(L.play, "Play Challenge", hv.play, WC_UI_GOOD, _can_play)

var _can_upload = (_can_play && ok_cheats)
var _up_label = "Upload to Workshop"
var _up_accent = WC_UI_GOOD
if _can_upload && !ok_beaten {
	_up_label = "Beat it first to upload"
	_up_accent = WC_UI_WARN
}
scr_workshopchallenge_ui_button(L.upload, _up_label, hv.upload, _up_accent, _can_upload)

gpu_set_texfilter(_filter)
scr_workshopchallenge_ui_reset()
