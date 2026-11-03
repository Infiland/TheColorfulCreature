if (!timing_instance_step()) exit;

// Modal popup blocks this menu. Input stays held for a few ticks afterwards so
// the click that dismissed the popup is not also used on whatever is underneath.
if instance_exists(o_popup) {
	input_hold = 3
	window_set_cursor(cr_default)
	exit
}
if input_hold > 0 { input_hold -= 1 }
var _live = (input_hold <= 0)

var mx = mouse_x
var my = mouse_y
var clicked = _live && (timing_mouse_pressed(mb_left) || gamepad_ui_pressed(gp_face1))
var _back = _live && (timing_keyboard_pressed(vk_escape) || gamepad_ui_pressed(gp_face2))

// Esc / B: leave a text field first, then close
if _back {
	if editing != 0 {
		scr_workshopchallenge_creator_set_edit(id, 0)
	} else {
		instance_destroy()
		exit
	}
}

// Text fields
if editing != 0 && _live && timing_keyboard_pressed(vk_enter) {
	scr_workshopchallenge_creator_set_edit(id, 0)
}
if editing = 1 {
	badwords()
	if string_length(keyboard_string) > 40 {
		keyboard_string = string_copy(keyboard_string,1,40)
	}
	title = keyboard_string
} else if editing = 2 {
	if string_length(keyboard_string) > 24 {
		keyboard_string = string_copy(keyboard_string,1,24)
	}
	search = keyboard_string
}

// Lay out the level grid for the current tab + search
var my_steam_id = tcc_steam_get_user_steam_id()
var _query = string_lower(search)
var _card_dx = L.card_w + L.gap_x
var _card_dy = L.card_h + L.gap_y
total_count = array_length(level_buttons)
visible_count = 0
owned_count = 0
unloaded_count = 0

for (var i = 0; i < array_length(level_buttons); i++) {
	var btn = level_buttons[i]
	if !instance_exists(btn) { continue }

	var _mine = (btn.loaded == 1 && btn.owner_id == my_steam_id)
	if btn.loaded != 1 { unloaded_count += 1 }
	if _mine { owned_count += 1 }

	var _show = (filter_mode == 0) || _mine
	if _show && _query != "" {
		_show = (btn.loaded == 1 && string_pos(_query, btn.mTitle_lc) > 0)
	}

	var _was_hidden = (btn.filtered_out == 1)
	btn.filtered_out = _show ? 0 : 1
	if _show {
		btn.base_x = L.list[0] + (visible_count mod L.cols) * _card_dx
		btn.base_y = L.list[1] + (visible_count div L.cols) * _card_dy
		// Cards that were hidden appear in place instead of flying in from where they were
		if _was_hidden {
			btn.x = btn.base_x
			btn.y = btn.base_y - global.workshopchallenge_scroll
		}
		visible_count += 1
	}
}

var _list_h = L.list[3] - L.list[1]
var _rows = ceil(visible_count / L.cols)
var _content_h = max(0, _rows * _card_dy - L.gap_y)
global.workshopchallenge_scrollmax = max(0, _content_h - _list_h)

// What is the pointer over?
hot = ""
hot_i = -1
hot_j = -1
hover_tile = noone
var _seq_x2 = L.seq[2] - 12
var _seq_count = array_length(selection)

if scr_workshopchallenge_ui_in(mx, my, L.close) { hot = "close" }
else if scr_workshopchallenge_ui_in(mx, my, L.tab_sub) { hot = "tab0" }
else if scr_workshopchallenge_ui_in(mx, my, L.tab_my) { hot = "tab1" }
else if scr_workshopchallenge_ui_in(mx, my, L.search) {
	hot = "search"
	if search != "" && scr_workshopchallenge_ui_in(mx, my, L.search_clear) { hot = "searchclear" }
}
else if visible_count > 0 && scr_workshopchallenge_ui_in(mx, my, L.select_all) { hot = "selall" }
else if scr_workshopchallenge_ui_in(mx, my, L.title_box) { hot = "title" }
else if _seq_count > 0 && scr_workshopchallenge_ui_in(mx, my, L.seq_clear) { hot = "clear" }
else if scr_workshopchallenge_ui_in(mx, my, L.seq) {
	var _row = floor((my - L.seq[1]) / L.seq_pitch)
	var _idx = seq_first + _row
	if _row >= 0 && _row < L.seq_rows && _idx < _seq_count && (my - L.seq[1]) - _row * L.seq_pitch <= L.seq_row_h {
		hot = "seq"
		hot_i = _idx
		if mx >= _seq_x2 - 30 && mx <= _seq_x2 - 6 { hot_j = 2 }
		else if mx >= _seq_x2 - 58 && mx <= _seq_x2 - 34 { hot_j = 1 }
		else if mx >= _seq_x2 - 86 && mx <= _seq_x2 - 62 { hot_j = 0 }
	}
}
else if scr_workshopchallenge_ui_in(mx, my, L.play) { hot = "play" }
else if scr_workshopchallenge_ui_in(mx, my, L.upload) { hot = "upload" }
else if global.workshopchallenge_scrollmax > 0 && point_in_rectangle(mx, my, L.sb[0] - 6, L.sb[1], L.sb[2] + 2, L.sb[3]) { hot = "scrollbar" }
else if !sb_drag && scr_workshopchallenge_ui_in(mx, my, L.list) {
	for (var h = 0; h < array_length(level_buttons); h++) {
		var hb = level_buttons[h]
		if instance_exists(hb) && hb.filtered_out != 1 {
			if point_in_rectangle(mx, my, hb.x, hb.y, hb.x + L.card_w, hb.y + L.card_h) {
				hover_tile = hb
				hot = "tile"
			}
		}
	}
}

// Clicks
if clicked {
	// Clicking anywhere but a text field leaves it
	if editing != 0 && hot != "title" && hot != "search" && hot != "searchclear" {
		scr_workshopchallenge_creator_set_edit(id, 0)
	}

	switch (hot) {
	case "close":
		instance_destroy()
		exit
	case "tab0":
		filter_mode = 0
		global.workshopchallenge_scroll = 0
		break
	case "tab1":
		filter_mode = 1
		global.workshopchallenge_scroll = 0
		break
	case "search":
		if editing != 2 { scr_workshopchallenge_creator_set_edit(id, 2) }
		break
	case "searchclear":
		search = ""
		if editing = 2 { keyboard_string = "" }
		global.workshopchallenge_scroll = 0
		break
	case "title":
		if editing != 1 { scr_workshopchallenge_creator_set_edit(id, 1) }
		break
	case "selall":
		// Everything shown is picked already: unpick it, otherwise pick what is missing
		var _all_picked = 1
		for (var a = 0; a < array_length(level_buttons); a++) {
			var ab = level_buttons[a]
			if instance_exists(ab) && ab.filtered_out != 1 && scr_workshopchallenge_ui_index_of(selection, ab) < 0 { _all_picked = 0 }
		}
		for (var a2 = 0; a2 < array_length(level_buttons); a2++) {
			var ab2 = level_buttons[a2]
			if !instance_exists(ab2) || ab2.filtered_out = 1 { continue }
			var _has = scr_workshopchallenge_ui_index_of(selection, ab2) >= 0
			if _all_picked = 1 || !_has { scr_workshopchallenge_creator_toggle(id, ab2) }
		}
		break
	case "clear":
		selection = []
		seq_first = 0
		break
	case "seq":
		if hot_j = 0 { scr_workshopchallenge_creator_move(id, hot_i, -1) }
		else if hot_j = 1 { scr_workshopchallenge_creator_move(id, hot_i, 1) }
		else if hot_j = 2 { array_delete(selection, hot_i, 1) }
		break
	case "tile":
		scr_workshopchallenge_creator_toggle(id, hover_tile)
		break
	case "play":
		scr_workshopchallenge_creator_play(id)
		break
	case "upload":
		scr_workshopchallenge_creator_upload(id)
		break
	case "scrollbar":
		sb_drag = 1
		if my >= sb_thumb_y && my <= sb_thumb_y + sb_thumb_h {
			sb_drag_off = my - sb_thumb_y
		} else {
			sb_drag_off = sb_thumb_h / 2
		}
		break
	}
}

// Scrolling: wheel (library, or the sequence list when over the challenge panel), right stick, scrollbar drag
var _wheel = 0
if timing_mouse_wheel_up() { _wheel -= 1 }
if timing_mouse_wheel_down() { _wheel += 1 }
if _wheel != 0 {
	if scr_workshopchallenge_ui_in(mx, my, L.side) {
		seq_first += _wheel
	} else {
		global.workshopchallenge_scroll += _wheel * 64
	}
}
var _stick = gamepad_ui_axis(gp_axisrv)
if abs(_stick) > 0.2 { global.workshopchallenge_scroll += 14 * _stick }

if sb_drag {
	if timing_mouse_down(mb_left) || gamepad_ui_down(gp_face1) {
		var _track = L.sb[3] - L.sb[1]
		var _t = (my - sb_drag_off - L.sb[1]) / max(1, _track - sb_thumb_h)
		global.workshopchallenge_scroll = clamp(_t, 0, 1) * global.workshopchallenge_scrollmax
	} else {
		sb_drag = 0
	}
}

global.workshopchallenge_scroll = clamp(global.workshopchallenge_scroll, 0, global.workshopchallenge_scrollmax)
seq_first = clamp(seq_first, 0, max(0, array_length(selection) - L.seq_rows))

sb_thumb_h = 0
sb_thumb_y = L.sb[1]
if global.workshopchallenge_scrollmax > 0 {
	var _sb_track = L.sb[3] - L.sb[1]
	sb_thumb_h = max(44, _sb_track * (_list_h / (_list_h + global.workshopchallenge_scrollmax)))
	sb_thumb_y = L.sb[1] + (global.workshopchallenge_scroll / global.workshopchallenge_scrollmax) * (_sb_track - sb_thumb_h)
}

// Selection state: position in the sequence is the play order
for (var s = array_length(selection) - 1; s >= 0; s--) {
	if !instance_exists(selection[s]) { array_delete(selection, s, 1) }
}
for (var u = 0; u < array_length(level_buttons); u++) {
	var ub = level_buttons[u]
	if instance_exists(ub) {
		ub.selected = 0
		ub.selected_order = 0
	}
}

selected_count = array_length(selection)
diamond_sum = 0
var diff_sum = 0
draft_ids = []
for (var p = 0; p < selected_count; p++) {
	var sb = selection[p]
	sb.selected = 1
	sb.selected_order = p + 1
	diamond_sum += sb.diamond_time
	diff_sum += sb.difficulty
	draft_ids[p] = sb.level
}
difficulty_avg = (selected_count > 0) ? diff_sum / selected_count : 0

all_shown_picked = 0
if visible_count > 0 {
	all_shown_picked = 1
	for (var w = 0; w < array_length(level_buttons); w++) {
		var wb = level_buttons[w]
		if instance_exists(wb) && wb.filtered_out != 1 && wb.selected != 1 { all_shown_picked = 0 }
	}
}

signature_current = scr_workshopchallenge_signature(title, draft_ids)
ok_title = (title != "")
ok_levels = (selected_count > 0)
ok_cheats = (global.cheats == 0)
ok_beaten = (ok_title && ok_levels && global.workshopchallenge_beaten_signature == signature_current)

// Hover animation + cursor
var _names = variable_struct_get_names(hv)
for (var n = 0; n < array_length(_names); n++) {
	var _name = _names[n]
	hv[$ _name] = lerp(hv[$ _name], (hot == _name) ? 1 : 0, 0.3)
}
for (var t = 0; t < array_length(level_buttons); t++) {
	var tb = level_buttons[t]
	if instance_exists(tb) { tb.hov = lerp(tb.hov, (tb == hover_tile) ? 1 : 0, 0.3) }
}

var _cursor = cr_default
if hot == "title" || hot == "search" { _cursor = cr_beam }
else if hot == "seq" { if hot_j >= 0 { _cursor = cr_handpoint } }
else if hot != "" { _cursor = cr_handpoint }
window_set_cursor(_cursor)
