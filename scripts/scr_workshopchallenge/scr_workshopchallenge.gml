function scr_workshopchallenge_signature(_title, _levels) {
	var _sig = string(_title);
	if (!is_array(_levels)) return _sig;

	var _ids = ds_list_create();
	for (var i = 0; i < array_length(_levels); i++) {
		var _entry = _levels[i];
		var _id = _entry;
		if (is_struct(_entry) && variable_struct_exists(_entry, "id")) {
			_id = _entry.id;
		}
		ds_list_add(_ids, _id);
	}
	ds_list_sort(_ids, true);
	for (var j = 0; j < ds_list_size(_ids); j++) {
		_sig += "|" + string(_ids[| j]);
	}
	ds_list_destroy(_ids);
	return _sig;
}

function scr_workshopchallenge_save_progress() {
	var _dir = directory_set("//Save Files/")
	if !directory_exists(_dir) { directory_create(_dir) }
	if file_exists(_dir + "WorkshopChallenges.sav") { file_delete(_dir + "WorkshopChallenges.sav") }
	ini_open(_dir + "WorkshopChallenges.sav")
	ini_write_string("Workshop Challenges", "Beaten Signature", global.workshopchallenge_beaten_signature)
	ini_close()
}

function scr_workshopchallenge_abort() {
	// Abort is only meaningful for an active sequence. A stale caller must not
	// clear an unrelated packaged challenge or standalone Workshop run.
	if (!variable_global_exists("workshopchallenge") || global.workshopchallenge != 1) return false;
	global.workshopchallenge = 0
	global.workshopchallenge_title = ""
	global.workshopchallenge_levels = []
	global.workshopchallenge_index = 0
	global.workshopchallenge_diamond_time = 0
	global.workshopchallenge_difficulty = 0
	global.workshopchallenge_signature = ""
	global.workshopchallenge_is_draft = 0
	global.workshopchallenge_return_to_creator = 0
	global.workshopfolder = ""
	global.workshop = 0
	global.challenges = 0
	global.challenge_run_id = -1
	global.level_document_context = ""
	return true;
}

/// A load failure after start/restart/advance must leave the old completed room.
/// Pre-start validation uses its own popup and never calls this recovery path.
function scr_workshopchallenge_load_failure(_message) {
	if (!variable_global_exists("workshopchallenge") || global.workshopchallenge != 1) return false;
	level_error(_message);
	level_load_failure();
	return false;
}

function scr_workshopchallenge_restart() {
	if (!variable_global_exists("workshopchallenge") || global.workshopchallenge != 1) return;
	global.time = 0
	global.deaths = 0
	global.pickup = 0
	scr_resetcheckpointdata()
	global.workshopchallenge_index = 0
	scr_workshopchallenge_goto_level(global.workshopchallenge_index)
}

function scr_workshopchallenge_advance() {
	if (!variable_global_exists("workshopchallenge") || global.workshopchallenge != 1) return;
	global.pickup = 0
	scr_resetcheckpointdata()

	global.workshopchallenge_index += 1
	if (global.workshopchallenge_index < array_length(global.workshopchallenge_levels)) {
		scr_workshopchallenge_goto_level(global.workshopchallenge_index)
	} else {
		scr_workshopchallenge_complete()
	}
}

function scr_workshopchallenge_complete() {
	if (global.workshopchallenge_is_draft == 1 && global.workshopchallenge_signature != "") {
		global.workshopchallenge_beaten_signature = global.workshopchallenge_signature
		scr_workshopchallenge_save_progress()
		global.workshopchallenge_return_to_creator = 1
	}

	global.levelname = global.workshopchallenge_title
	room_goto(r_workshoplevelwin)
}

function scr_workshopchallenge_goto_level(_index) {
	if (!variable_global_exists("workshopchallenge") || global.workshopchallenge != 1) return;
	if (_index < 0 || _index >= array_length(global.workshopchallenge_levels)) {
		return scr_workshopchallenge_load_failure("The Workshop challenge level is no longer available.");
	}
	if (!global.steam_api) {
		return scr_workshopchallenge_load_failure("Steam is unavailable; the Workshop challenge could not continue.");
	}

	var _level = global.workshopchallenge_levels[_index];
	var _level_id = _level;
	var _level_title = "Workshop Level";
	if (is_struct(_level)) {
		if (variable_struct_exists(_level, "id")) _level_id = _level.id;
		if (variable_struct_exists(_level, "title")) _level_title = _level.title;
	}

	var _info = ds_map_create();
	tcc_steam_ugc_get_item_install_info(_level_id, _info);
	var _folder = "";
	if (ds_map_exists(_info, "folder")) _folder = _info[? "folder"];
	ds_map_destroy(_info);

	_folder = string_replace_all(string(_folder), "\\", "/");
	if (_folder == "") {
		return scr_workshopchallenge_load_failure("Missing subscribed workshop level: " + string(_level_id));
	}
	if (string_copy(_folder, string_length(_folder), 1) != "/") _folder += "/"

	global.workshopfolder = _folder
	global.Publish_ID = _level_id
	global.levelname = _level_title

	if (!level_prepare_room(_folder, r_customlevelworkshop, true)) {
        return scr_workshopchallenge_load_failure(global.level_last_error);
    }
    scr_leveleditormusic(_folder);

	loadhud()
	if !instance_exists(o_narrator) { instance_create(0,0,o_narrator) }
	instance_destroy(o_coincounter)

	room_goto(r_customlevelworkshop)
}

function scr_workshopchallenge_validate_levels(_challenge) {
	var _result = { valid: true, missing: [] };
	if (!is_struct(_challenge)) return _result;
	if (!variable_struct_exists(_challenge, "levels")) return _result;
	if (!is_array(_challenge.levels)) return _result;
	if (!global.steam_api) return _result;

	for (var i = 0; i < array_length(_challenge.levels); i++) {
		var _level = _challenge.levels[i];
		var _level_id = _level;
		var _level_title = "Workshop Level";
		if (is_struct(_level)) {
			if (variable_struct_exists(_level, "id")) _level_id = _level.id;
			if (variable_struct_exists(_level, "title")) _level_title = _level.title;
		}

		var _info = ds_map_create();
		tcc_steam_ugc_get_item_install_info(_level_id, _info);
		var _folder = "";
		if (ds_map_exists(_info, "folder")) _folder = _info[? "folder"];
		ds_map_destroy(_info);

		_folder = string_replace_all(string(_folder), "\\", "/");
		if (_folder != "" && string_copy(_folder, string_length(_folder), 1) != "/") _folder += "/";

		if (_folder == "" || is_undefined(level_read(_folder))) {
			_result.valid = false;
			array_push(_result.missing, { id: _level_id, title: _level_title });
		}
	}
	return _result;
}

function scr_workshopchallenge_start(_challenge) {
	if (!global.steam_api) return;
	if (is_undefined(_challenge)) return;
	if (!is_struct(_challenge)) return;
	if (!variable_struct_exists(_challenge, "levels")) return;
	if (!is_array(_challenge.levels) || array_length(_challenge.levels) <= 0) return;

	// Validate all levels are subscribed and installed
	var _validation = scr_workshopchallenge_validate_levels(_challenge);
	if (!_validation.valid) {
		var _msg = "This challenge requires workshop levels you haven't subscribed to:";
		for (var i = 0; i < array_length(_validation.missing); i++) {
			var _m = _validation.missing[i];
			_msg += "\n- " + string(_m.title) + " (" + string(_m.id) + ")";
		}
		_msg += "\n\nSubscribe to these levels first.";
		if !instance_exists(o_popup) {
			global.popup_config = { title: "Workshop Challenge", message: _msg, mode: 0 }
			instance_create(0, 0, o_popup)
		}
		return;
	}

	global.challenges = 1
	global.workshop = 1
	global.workshopchallenge = 1

	global.workshopchallenge_title = variable_struct_exists(_challenge, "title") ? _challenge.title : "Workshop Challenge"
	global.workshopchallenge_levels = _challenge.levels
	global.workshopchallenge_index = 0
	global.workshopchallenge_diamond_time = variable_struct_exists(_challenge, "diamond_time") ? _challenge.diamond_time : 0
	global.workshopchallenge_difficulty = variable_struct_exists(_challenge, "difficulty") ? _challenge.difficulty : 0
	global.workshopchallenge_signature = scr_workshopchallenge_signature(global.workshopchallenge_title, global.workshopchallenge_levels)
	global.workshopchallenge_is_draft = variable_struct_exists(_challenge, "is_draft") ? _challenge.is_draft : 0

	global.DiamondMedalTimeChallenge = global.workshopchallenge_diamond_time
	global.time = 0
	global.deaths = 0
	global.pickup = 0
	scr_resetcheckpointdata()

	scr_workshopchallenge_goto_level(0)
}

function scr_workshopchallenge_load_from_folder(_folder) {
	var _path = string_replace_all(string(_folder), "\\", "/");
	if (_path == "") return undefined;
	if (string_copy(_path, string_length(_path), 1) != "/") _path += "/";
	if !file_exists(_path + "challenge.json") return undefined;

	var _data = LoadJSONFromFile(_path + "challenge.json");
	if (is_undefined(_data)) return undefined;
	var _type = "";
	if (ds_map_exists(_data, "type")) _type = _data[? "type"];
	if (_type != "workshop_challenge") {
		ds_map_destroy(_data);
		return undefined;
	}

	var _challenge = {};
	_challenge.title = ds_map_exists(_data, "title") ? _data[? "title"] : "Workshop Challenge";
	_challenge.diamond_time = ds_map_exists(_data, "diamond_time") ? _data[? "diamond_time"] : 0;
	_challenge.difficulty = ds_map_exists(_data, "difficulty") ? _data[? "difficulty"] : 0;
	_challenge.levels = [];

	if (ds_map_exists(_data, "levels")) {
		var _levels_list = _data[? "levels"];
		if (ds_exists(_levels_list, ds_type_list)) {
			var _count = ds_list_size(_levels_list);
			_challenge.levels = array_create(_count);
			for (var i = 0; i < _count; i++) {
				var _entry = _levels_list[| i];
				var _lvl = {};
				if (ds_exists(_entry, ds_type_map)) {
					_lvl.id = ds_map_exists(_entry, "id") ? _entry[? "id"] : 0;
					_lvl.title = ds_map_exists(_entry, "title") ? _entry[? "title"] : "Workshop Level";
					_lvl.diamond_time = ds_map_exists(_entry, "diamond_time") ? _entry[? "diamond_time"] : 0;
					_lvl.difficulty = ds_map_exists(_entry, "difficulty") ? _entry[? "difficulty"] : 0;
				} else {
					_lvl.id = _entry;
					_lvl.title = "Workshop Level";
					_lvl.diamond_time = 0;
					_lvl.difficulty = 0;
				}
				_challenge.levels[i] = _lvl;
			}
		}
	}

	// Fallback: recompute stats from level entries
	if (is_array(_challenge.levels) && array_length(_challenge.levels) > 0) {
		var _sum_time = 0;
		var _sum_diff = 0;
		for (var j = 0; j < array_length(_challenge.levels); j++) {
			var _lvl2 = _challenge.levels[j];
			if (is_struct(_lvl2)) {
				if (variable_struct_exists(_lvl2, "diamond_time")) _sum_time += _lvl2.diamond_time;
				if (variable_struct_exists(_lvl2, "difficulty")) _sum_diff += _lvl2.difficulty;
			}
		}
		if (_challenge.diamond_time == 0) _challenge.diamond_time = _sum_time;
		if (_challenge.difficulty == 0) _challenge.difficulty = _sum_diff / array_length(_challenge.levels);
	}

	ds_map_destroy(_data);
	return _challenge;
}

function scr_workshopchallenge_start_from_folder(_folder) {
	var _challenge = scr_workshopchallenge_load_from_folder(_folder);
	if (is_undefined(_challenge)) return;
	scr_workshopchallenge_start(_challenge);
}

// ---------------------------------------------------------------------------
// Create Workshop Challenge screen: shared layout, drawing and selection logic
// ---------------------------------------------------------------------------
#macro WC_UI_BG make_color_rgb(13, 13, 17)
#macro WC_UI_WELL make_color_rgb(18, 18, 24)
#macro WC_UI_PANEL make_color_rgb(24, 24, 31)
#macro WC_UI_PANEL_HI make_color_rgb(36, 36, 46)
#macro WC_UI_LINE make_color_rgb(64, 64, 78)
#macro WC_UI_DIM make_color_rgb(150, 150, 168)
#macro WC_UI_GOOD make_color_rgb(70, 235, 110)
#macro WC_UI_GOOD_DK make_color_rgb(20, 52, 34)
#macro WC_UI_WARN make_color_rgb(255, 205, 50)
#macro WC_UI_BAD make_color_rgb(255, 95, 95)
#macro WC_UI_DIAMOND make_color_rgb(90, 220, 255)

/// Every rectangle is [x1, y1, x2, y2] in room coordinates (1024 x 768).
function scr_workshopchallenge_layout() {
	var L = {};

	// Header
	L.close = [888, 20, 1000, 56];

	// Level library (left)
	L.tab_sub = [24, 92, 164, 128];
	L.tab_my = [170, 92, 310, 128];
	L.search = [334, 92, 644, 128];
	L.search_clear = [614, 96, 640, 124];
	L.select_all = [530, 134, 644, 158];
	L.info_y = 146;
	L.list = [24, 164, 644, 744];
	L.sb = [634, 164, 642, 744];
	L.card_w = 296;
	L.card_h = 104;
	L.gap_x = 12;
	L.gap_y = 12;
	L.cols = 2;

	// Challenge panel (right)
	L.side = [660, 92, 1000, 744];
	L.title_box = [660, 112, 1000, 152];
	L.seq_clear = [900, 162, 1000, 184];
	L.seq = [660, 190, 1000, 514];
	L.seq_row_h = 34;
	L.seq_pitch = 36;
	L.seq_rows = 9;
	L.seq_sb = [992, 190, 1000, 514];
	L.stats = [660, 524, 1000, 590];
	L.chips_y = 600;
	L.play = [660, 634, 1000, 686];
	L.upload = [660, 694, 1000, 744];
	return L;
}

function scr_workshopchallenge_ui_in(_mx, _my, _r) {
	return point_in_rectangle(_mx, _my, _r[0], _r[1], _r[2], _r[3]);
}

function scr_workshopchallenge_ui_index_of(_arr, _val) {
	for (var i = 0; i < array_length(_arr); i++) {
		if (_arr[i] == _val) return i;
	}
	return -1;
}

/// 45s below a minute, m:ss from then on.
function scr_workshopchallenge_ui_time(_secs) {
	var _t = max(0, round(_secs));
	if (_t < 60) return string(_t) + "s";
	var _s = _t mod 60;
	return string(_t div 60) + ":" + (_s < 10 ? "0" : "") + string(_s);
}

function scr_workshopchallenge_ui_difficulty_name(_diff) {
	var _names = ["Not rated", "Easy", "Medium", "Difficult", "Insane", "Unfair", "Impossible"];
	return _names[clamp(round(_diff), 0, 6)];
}

function scr_workshopchallenge_ui_text(_x, _y, _str, _scale, _col, _halign = fa_left, _valign = fa_top) {
	draw_set_font(global.deathfont);
	draw_set_halign(_halign);
	draw_set_valign(_valign);
	draw_set_color(_col);
	draw_text_transformed(_x, _y, string(_str), _scale, _scale, 0);
}

function scr_workshopchallenge_ui_reset() {
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);
	draw_set_alpha(1);
}

/// Rounded box; pass -1 as the border to leave it off.
function scr_workshopchallenge_ui_box(_r, _fill, _border, _radius = 6, _border_w = 1) {
	draw_set_color(_fill);
	draw_roundrect_ext(_r[0], _r[1], _r[2], _r[3], _radius, _radius, false);
	if (_border != -1) {
		draw_set_color(_border);
		for (var i = 0; i < _border_w; i++) {
			draw_roundrect_ext(_r[0] + i, _r[1] + i, _r[2] - i, _r[3] - i, _radius, _radius, true);
		}
	}
}

function scr_workshopchallenge_ui_button(_r, _label, _hov, _accent, _enabled, _scale = 0.85) {
	var _fill = WC_UI_PANEL;
	var _border = WC_UI_LINE;
	var _txt = WC_UI_DIM;
	if (_enabled) {
		_fill = merge_color(WC_UI_PANEL, _accent, 0.14 + 0.2 * _hov);
		_border = merge_color(_accent, c_white, 0.25 * _hov);
		_txt = merge_color(c_white, _accent, 0.25 * (1 - _hov));
	}
	scr_workshopchallenge_ui_box(_r, _fill, _border, 7, 2);
	scr_workshopchallenge_ui_text((_r[0] + _r[2]) / 2, (_r[1] + _r[3]) / 2, _label, _scale, _txt, fa_center, fa_middle);
}

function scr_workshopchallenge_ui_cross(_cx, _cy, _size, _col, _width = 2) {
	draw_set_color(_col);
	draw_line_width(_cx - _size, _cy - _size, _cx + _size, _cy + _size, _width);
	draw_line_width(_cx - _size, _cy + _size, _cx + _size, _cy - _size, _width);
}

function scr_workshopchallenge_ui_check(_cx, _cy, _col, _scale = 1) {
	draw_set_color(_col);
	draw_line_width(_cx - 4 * _scale, _cy, _cx - 1.5 * _scale, _cy + 3.5 * _scale, 2);
	draw_line_width(_cx - 1.5 * _scale, _cy + 3.5 * _scale, _cx + 4.5 * _scale, _cy - 4 * _scale, 2);
}

function scr_workshopchallenge_ui_arrow(_cx, _cy, _up, _col) {
	draw_set_color(_col);
	if (_up) {
		draw_triangle(_cx, _cy - 4, _cx - 5, _cy + 3, _cx + 5, _cy + 3, false);
	} else {
		draw_triangle(_cx, _cy + 4, _cx - 5, _cy - 3, _cx + 5, _cy - 3, false);
	}
}

function scr_workshopchallenge_ui_diamond(_cx, _cy, _r, _col) {
	draw_set_color(_col);
	draw_triangle(_cx - _r, _cy, _cx, _cy - _r * 1.25, _cx + _r, _cy, false);
	draw_triangle(_cx - _r, _cy, _cx, _cy + _r * 1.25, _cx + _r, _cy, false);
}

function scr_workshopchallenge_ui_search_icon(_cx, _cy, _col) {
	draw_set_color(_col);
	draw_circle(_cx - 1, _cy - 1, 6, true);
	draw_circle(_cx - 1, _cy - 1, 5, true);
	draw_line_width(_cx + 3, _cy + 3, _cx + 8, _cy + 8, 2);
}

/// Player faces, one per difficulty step. _x is the left edge of the first slot.
function scr_workshopchallenge_ui_difficulty(_x, _cy, _diff, _scale, _step) {
	var _n = clamp(round(_diff), 0, 6);
	if (_n <= 0) return;
	var _sprites = [noone, s_playerwhite, s_playerblue, s_playergreen, s_playeryellow, s_playerred, s_playerdead];
	var _frame = (_n == 6) ? 5 : 0;
	draw_set_color(c_white);
	for (var i = 0; i < _n; i++) {
		// Sprites are 32x32 with the artwork centred on (15.5, 15), origin top-left.
		draw_sprite_ext(_sprites[_n], _frame, _x + _step * 0.5 + i * _step - 15.5 * _scale, _cy - 15 * _scale, _scale, _scale, 0, c_white, 1);
	}
}

/// Splits _str into at most _maxlines lines no wider than _maxw (at _scale),
/// breaking on spaces where possible and ending with "..." if it is cut.
/// Uses the current draw font.
function scr_workshopchallenge_ui_wrap(_str, _maxw, _scale, _maxlines) {
	var _lines = [];
	var _s = string(_str);
	while (_s != "" && array_length(_lines) < _maxlines) {
		var _last = (array_length(_lines) == _maxlines - 1);
		if (string_width(_s) * _scale <= _maxw) {
			array_push(_lines, _s);
			break;
		}
		var _n = string_length(_s);
		var _fit = 1;
		var _limit = _last ? _maxw - string_width("...") * _scale : _maxw;
		for (var i = 1; i <= _n; i++) {
			if (string_width(string_copy(_s, 1, i)) * _scale > _limit) break;
			_fit = i;
		}
		if (_last) {
			var _head = string_copy(_s, 1, _fit);
			while (string_char_at(_head, string_length(_head)) == " ") { _head = string_delete(_head, string_length(_head), 1); }
			array_push(_lines, _head + "...");
			break;
		}
		var _cut = _fit;
		for (var k = _fit; k > 1; k--) {
			if (string_char_at(_s, k) == " ") { _cut = k - 1; break; }
		}
		array_push(_lines, string_copy(_s, 1, _cut));
		_s = string_copy(_s, _cut + 1, _n - _cut);
		while (string_char_at(_s, 1) == " ") { _s = string_delete(_s, 1, 1); }
	}
	return _lines;
}

/// Drops characters from the start until the text fits, so a long entry in a
/// text field still shows the end being typed. Uses the current draw font.
function scr_workshopchallenge_ui_tail(_str, _maxw, _scale) {
	var _s = string(_str);
	while (_s != "" && string_width(_s) * _scale > _maxw) { _s = string_delete(_s, 1, 1); }
	return _s;
}

/// Commits the field being edited, then starts editing _mode (0 none, 1 title, 2 search).
function scr_workshopchallenge_creator_set_edit(_c, _mode) {
	with (_c) {
		if (editing == 1) { title = keyboard_string; }
		else if (editing == 2) { search = keyboard_string; }
		editing = _mode;
		if (_mode == 1) { keyboard_string = title; }
		else if (_mode == 2) { keyboard_string = search; }
		else { keyboard_string = ""; }
	}
}

/// Adds the level to the end of the sequence, or removes it if already picked.
function scr_workshopchallenge_creator_toggle(_c, _btn) {
	with (_c) {
		var _pos = scr_workshopchallenge_ui_index_of(selection, _btn);
		if (_pos >= 0) {
			array_delete(selection, _pos, 1);
		} else {
			array_push(selection, _btn);
			seq_first = max(0, array_length(selection) - L.seq_rows);
		}
	}
}

/// Moves the entry at _pos by _dir (-1 earlier, +1 later) in the sequence.
function scr_workshopchallenge_creator_move(_c, _pos, _dir) {
	with (_c) {
		var _to = _pos + _dir;
		if (_pos < 0 || _to < 0 || _pos >= array_length(selection) || _to >= array_length(selection)) exit;
		var _tmp = selection[_pos];
		selection[_pos] = selection[_to];
		selection[_to] = _tmp;
	}
}

/// Builds the draft struct and the level id list from the picked levels, in play order.
function scr_workshopchallenge_creator_draft(_c) {
	var _draft = { title: string(_c.title), levels: [], diamond_time: 0, difficulty: 0, is_draft: 1 };
	var _ids = [];
	var _diamond = 0;
	var _diff = 0;
	for (var i = 0; i < array_length(_c.selection); i++) {
		var _btn = _c.selection[i];
		if (!instance_exists(_btn)) continue;
		array_push(_draft.levels, { id: _btn.level, title: _btn.mTitle, diamond_time: _btn.diamond_time, difficulty: _btn.difficulty });
		array_push(_ids, _btn.level);
		_diamond += _btn.diamond_time;
		_diff += _btn.difficulty;
	}
	var _count = array_length(_draft.levels);
	if (_count > 0) {
		_draft.diamond_time = _diamond;
		_draft.difficulty = _diff / _count;
	}
	return { draft: _draft, ids: _ids };
}

function scr_workshopchallenge_creator_popup(_message) {
	if (instance_exists(o_popup)) return;
	global.popup_config = { title: "Workshop Challenge", message: _message, mode: 0 };
	instance_create(0, 0, o_popup);
}

/// Play: starts the picked levels as a draft challenge.
function scr_workshopchallenge_creator_play(_c) {
	if (_c.title == "") { scr_workshopchallenge_creator_popup("Give your challenge a title first."); return; }
	var _built = scr_workshopchallenge_creator_draft(_c);
	if (array_length(_built.ids) <= 0) { scr_workshopchallenge_creator_popup("Add at least one level first."); return; }

	global.workshopchallenge_draft = _built.draft;
	global.workshopchallenge_draft_title = _built.draft.title;
	global.workshopchallenge_draft_level_ids = _built.ids;
	scr_workshopchallenge_start(_built.draft);
}

/// Upload: opens the publish screen once the player has beaten this exact challenge.
function scr_workshopchallenge_creator_upload(_c) {
	if (global.cheats != 0) { scr_workshopchallenge_creator_popup("Cheats must be disabled to upload."); return; }
	var _built = scr_workshopchallenge_creator_draft(_c);
	if (_c.title == "" || array_length(_built.ids) <= 0) {
		scr_workshopchallenge_creator_popup("Add levels and give your challenge a title first.");
		return;
	}

	var _sig = scr_workshopchallenge_signature(_built.draft.title, _built.ids);
	if (global.workshopchallenge_beaten_signature == _sig) {
		global.workshopchallenge_draft = _built.draft;
		global.workshopchallenge_draft_title = _built.draft.title;
		global.workshopchallenge_draft_level_ids = _built.ids;
		if (!instance_exists(o_publishworkshopchallenge)) instance_create(0, 0, o_publishworkshopchallenge);
		return;
	}

	if (instance_exists(o_popup)) return;
	global.workshopchallenge_pending_draft = _built.draft;
	global.workshopchallenge_pending_title = _built.draft.title;
	global.workshopchallenge_pending_level_ids = _built.ids;
	global.popup_config = {
		title: "Workshop Challenge",
		message: "Beat your challenge first to upload it.\nTry to beat it now?",
		mode: 1,
		yes_text: "Play",
		no_text: "Cancel",
		cb_yes: function() {
			global.workshopchallenge_draft = global.workshopchallenge_pending_draft
			global.workshopchallenge_draft_title = global.workshopchallenge_pending_title
			global.workshopchallenge_draft_level_ids = global.workshopchallenge_pending_level_ids
			scr_workshopchallenge_start(global.workshopchallenge_pending_draft)

			global.workshopchallenge_pending_draft = undefined
			global.workshopchallenge_pending_title = undefined
			global.workshopchallenge_pending_level_ids = undefined
		},
		cb_no: function() {
			global.workshopchallenge_pending_draft = undefined
			global.workshopchallenge_pending_title = undefined
			global.workshopchallenge_pending_level_ids = undefined
		}
	};
	instance_create(0, 0, o_popup);
}

/// Draws one level card. Runs in the scope of an o_workshoplevelselectbutton;
/// the creator owns hit-testing, hover and which cards are shown.
function scr_workshopchallenge_draw_card() {
	if (filtered_out == 1) return;
	if (!instance_exists(o_workshopchallengecreator)) return;
	var L = o_workshopchallengecreator.L;
	var _x1 = round(x);
	var _y1 = round(y);
	if (_y1 > L.list[3] || _y1 + L.card_h < L.list[1]) return;
	var _x2 = _x1 + L.card_w;
	var _y2 = _y1 + L.card_h;
	var _sel = (selected == 1);
	var _filter = gpu_get_texfilter();
	gpu_set_texfilter(true);

	// Card
	var _fill = _sel ? merge_color(WC_UI_GOOD_DK, merge_color(WC_UI_GOOD_DK, WC_UI_GOOD, 0.18), hov) : merge_color(WC_UI_PANEL, WC_UI_PANEL_HI, hov);
	var _border = _sel ? WC_UI_GOOD : merge_color(WC_UI_LINE, c_white, hov * 0.5);
	scr_workshopchallenge_ui_box([_x1, _y1, _x2, _y2], _fill, _border, 8, _sel ? 2 : 1);

	// Thumbnail
	var _tx1 = _x1 + 8;
	var _ty1 = _y1 + 8;
	var _tw = 112;
	var _th = L.card_h - 16;
	draw_set_color(c_black);
	draw_rectangle(_tx1, _ty1, _tx1 + _tw, _ty1 + _th, false);
	if (thumb_spr != -1) {
		var _sw = sprite_get_width(thumb_spr);
		var _sh = sprite_get_height(thumb_spr);
		var _scale = min(_tw / _sw, _th / _sh);
		draw_sprite_ext(thumb_spr, 0, _tx1 + (_tw - _sw * _scale) / 2, _ty1 + (_th - _sh * _scale) / 2, _scale, _scale, 0, c_white, 1);
	} else {
		scr_workshopchallenge_ui_text(_tx1 + _tw / 2, _ty1 + _th / 2, "No preview", 0.55, WC_UI_LINE, fa_center, fa_middle);
	}

	// Position in the challenge
	if (_sel) {
		var _num = string(selected_order);
		draw_set_font(global.deathfont);
		var _bw = max(26, string_width(_num) * 0.66 + 14);
		scr_workshopchallenge_ui_box([_tx1 + 4, _ty1 + _th - 26, _tx1 + 4 + _bw, _ty1 + _th - 4], WC_UI_GOOD, -1, 6);
		scr_workshopchallenge_ui_text(_tx1 + 4 + _bw / 2, _ty1 + _th - 15, _num, 0.66, WC_UI_BG, fa_center, fa_middle);
	}

	// Selection marker
	var _mx = _x2 - 20;
	var _my = _y1 + 20;
	if (_sel) {
		draw_set_color(WC_UI_GOOD);
		draw_circle(_mx, _my, 10, false);
		scr_workshopchallenge_ui_check(_mx, _my, WC_UI_BG, 1);
	} else {
		draw_set_color(merge_color(WC_UI_LINE, c_white, hov * 0.7));
		draw_circle(_mx, _my, 10, true);
		draw_circle(_mx, _my, 9, true);
	}

	// Title (cached; wrapping measures text)
	var _text_x = _x1 + 128;
	var _title_w = (_x2 - 36) - _text_x;
	if (fit_key != mTitle) {
		draw_set_font(global.deathfont);
		fit_lines = scr_workshopchallenge_ui_wrap(mTitle, _title_w, 0.7, 2);
		fit_key = mTitle;
	}
	var _title_col = (loaded == 1) ? c_white : WC_UI_DIM;
	for (var i = 0; i < array_length(fit_lines); i++) {
		scr_workshopchallenge_ui_text(_text_x, _y1 + 20 + i * 20, fit_lines[i], 0.7, _title_col, fa_left, fa_middle);
	}

	// Diamond time
	scr_workshopchallenge_ui_diamond(_text_x + 6, _y1 + 68, 5, WC_UI_DIAMOND);
	scr_workshopchallenge_ui_text(_text_x + 18, _y1 + 68, scr_workshopchallenge_ui_time(diamond_time), 0.66, WC_UI_DIAMOND, fa_left, fa_middle);

	// Difficulty
	if (round(difficulty) > 0) {
		scr_workshopchallenge_ui_difficulty(_text_x, _y1 + 87, difficulty, 0.6, 19);
	} else {
		scr_workshopchallenge_ui_text(_text_x, _y1 + 87, "Not rated", 0.58, WC_UI_DIM, fa_left, fa_middle);
	}

	gpu_set_texfilter(_filter);
	scr_workshopchallenge_ui_reset();
}
