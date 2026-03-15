function scr_challenge_key(_id) {
	return string(_id);
}

function scr_challenge_map_get(_map, _key, _default) {
	if (is_undefined(_map)) return _default;
	if (ds_map_exists(_map, _key)) return _map[? _key];
	return _default;
}

function scr_map_keys(_map) {
	var _keys = ds_list_create();
	if (ds_exists(_map, ds_type_map)) {
		var _key = ds_map_find_first(_map);
		while (!is_undefined(_key)) {
			ds_list_add(_keys, _key);
			_key = ds_map_find_next(_map, _key);
		}
	}
	return _keys;
}

function scr_challenge_list_to_array(_list) {
	if (!ds_exists(_list, ds_type_list)) return [];
	var _count = ds_list_size(_list);
	var _array = array_create(_count);
	for (var i = 0; i < _count; i++) {
		_array[i] = _list[| i];
	}
	return _array;
}

function scr_challenge_get_base_dir() {
	var _roots = [];
	_roots[0] = string_replace_all(program_directory, "\\", "/");
	_roots[1] = string_replace_all(working_directory, "\\", "/");
	for (var i = 0; i < array_length(_roots); i++) {
		var _root = _roots[i];
		if (_root == "") continue;
		var _dir = _root + "/Challenges/";
		if (directory_exists(_dir)) return _dir;
		_dir = _root + "/datafiles/Challenges/";
		if (directory_exists(_dir)) return _dir;
	}
	return string_replace_all(program_directory, "\\", "/") + "/Challenges/";
}

function scr_challenge_def_from_map(_map, _is_custom) {
	var _def = {};
	var _custom_override = scr_challenge_map_get(_map, "is_custom", undefined);
	if (!is_undefined(_custom_override)) {
		_is_custom = (_custom_override == true) || (_custom_override == 1);
	}
	_def.id = scr_challenge_map_get(_map, "id", -1);
	_def.order = scr_challenge_map_get(_map, "order", -1);
	_def.title_loc = scr_challenge_map_get(_map, "title_loc", 0);
	_def.title_text = scr_challenge_map_get(_map, "title_text", "");
	_def.difficulty = scr_challenge_map_get(_map, "difficulty", 1);
	_def.diamond_time = scr_challenge_map_get(_map, "diamond_time", 9999);
	_def.room = scr_challenge_map_get(_map, "room", "");
	_def.rooms = scr_challenge_list_to_array(scr_challenge_map_get(_map, "rooms", undefined));
	_def.music = scr_challenge_map_get(_map, "music", "");
	_def.music_mode = scr_challenge_map_get(_map, "music_mode", "asset");
	_def.unlock_type = scr_challenge_map_get(_map, "unlock_type", "none");
	_def.unlock_value = scr_challenge_map_get(_map, "unlock_value", 0);
	_def.reward_credits = scr_challenge_map_get(_map, "reward_credits", 0);
	_def.reward_hat = scr_challenge_map_get(_map, "reward_hat", -1);
	_def.reward_hat_state = scr_challenge_map_get(_map, "reward_hat_state", 1);
	_def.reward_skins = scr_challenge_list_to_array(scr_challenge_map_get(_map, "reward_skins", undefined));
	if (array_length(_def.reward_skins) == 0) {
		var _reward_skin = scr_challenge_map_get(_map, "reward_skin", -1);
		if (_reward_skin >= 0) _def.reward_skins = [_reward_skin];
	}
	_def.bonus_skins = scr_challenge_list_to_array(scr_challenge_map_get(_map, "bonus_skins", undefined));
	_def.bonus_deaths_max = scr_challenge_map_get(_map, "bonus_deaths_max", -1);
	_def.achievement = scr_challenge_map_get(_map, "achievement", "");
	_def.leaderboard = scr_challenge_map_get(_map, "leaderboard", "");
	_def.leaderboard_mobile = scr_challenge_map_get(_map, "leaderboard_mobile", "");
	_def.demo_blocked = scr_challenge_map_get(_map, "demo_blocked", 0);
	_def.save_key = scr_challenge_map_get(_map, "save_key", "");
	_def.time_var = scr_challenge_map_get(_map, "time_var", "");
	_def.deaths_var = scr_challenge_map_get(_map, "deaths_var", "");
	_def.win_room = scr_challenge_map_get(_map, "win_room", "");
	_def.level_dir = scr_challenge_map_get(_map, "level_dir", "");
	_def.level_dirs = scr_challenge_list_to_array(scr_challenge_map_get(_map, "level_dirs", undefined));
	if (array_length(_def.level_dirs) == 0 && _def.level_dir != "") _def.level_dirs = [_def.level_dir];
	_def.is_custom = _is_custom;
	_def.enabled = scr_challenge_map_get(_map, "enabled", 1);
	return _def;
}

function scr_challenges_register(_def, _allow_override) {
	if (argument_count < 2) _allow_override = false;
	if (!variable_global_exists("challenge_next_id")) global.challenge_next_id = 1000;
	if (_def.id == -1) {
		_def.id = global.challenge_next_id;
		global.challenge_next_id += 1;
	}
	var _key = scr_challenge_key(_def.id);
	if (ds_map_exists(global.challenge_defs, _key)) {
		if (_allow_override) {
			ds_map_replace(global.challenge_defs, _key, _def);
			if (ds_list_find_index(global.challenge_order, _def.id) < 0) {
				ds_list_add(global.challenge_order, _def.id);
			}
			return;
		}
		while (ds_map_exists(global.challenge_defs, _key)) {
			_def.id = global.challenge_next_id;
			global.challenge_next_id += 1;
			_key = scr_challenge_key(_def.id);
		}
	}
		if (_def.save_key == "") {
			if (_def.title_text != "") {
				_def.save_key = _def.title_text;
			} else {
				_def.save_key = "Challenge " + string(_def.id);
			}
		}
		ds_map_add(global.challenge_defs, _key, _def);
		if (ds_list_find_index(global.challenge_order, _def.id) < 0) {
			ds_list_add(global.challenge_order, _def.id);
		}
	}

function scr_challenges_sort_order() {
	if (!ds_exists(global.challenge_order, ds_type_list)) return;
	var _count = ds_list_size(global.challenge_order);
	if (_count <= 1) return;

	var _items = array_create(_count);
	for (var i = 0; i < _count; i++) {
		var _id = global.challenge_order[| i];
		var _order = 999999;
		var _def = scr_challenge_get_def(_id);
		if (!is_undefined(_def)) {
			_order = _def.order;
			if (_order < 0) _order = 999999;
		}
		_items[i] = { id: _id, order: _order, index: i };
	}

	for (var i = 1; i < _count; i++) {
		var _key = _items[i];
		var j = i - 1;
		while (j >= 0) {
			var _a = _items[j];
			if (_a.order < _key.order) break;
			if (_a.order == _key.order && _a.index <= _key.index) break;
			_items[j + 1] = _a;
			j -= 1;
		}
		_items[j + 1] = _key;
	}

	ds_list_clear(global.challenge_order);
	for (var i = 0; i < _count; i++) {
		var _id = _items[i].id;
		if (ds_list_find_index(global.challenge_order, _id) < 0) {
			ds_list_add(global.challenge_order, _id);
		}
	}
}

function scr_challenges_load_defs() {
	var _base_dir = scr_challenge_get_base_dir();
	var _file = _base_dir + "challenges.json";
	if (file_exists(_file)) {
		var _data = LoadJSONFromFile(_file);
		if (ds_map_exists(_data, "challenges")) {
			var _list = _data[? "challenges"];
			for (var i = 0; i < ds_list_size(_list); i++) {
				var _map = _list[| i];
				var _def = scr_challenge_def_from_map(_map, false);
				scr_challenges_register(_def, true);
			}
		}
		ds_map_destroy(_data);
	}

	var _dir = file_find_first(_base_dir + "*", fa_directory);
	while (_dir != "") {
		if (_dir != "." && _dir != "..") {
			var _custom_file = _base_dir + _dir + "/challenge.json";
			if (file_exists(_custom_file)) {
				var _custom_data = LoadJSONFromFile(_custom_file);
				var _custom_def = scr_challenge_def_from_map(_custom_data, true);
			if (_custom_def.level_dir == "") {
				if (file_exists(_base_dir + _dir + "/1/LevelEditor.sav")) {
					_custom_def.level_dir = _dir + "/1";
				} else if (file_exists(_base_dir + _dir + "/LevelEditor.sav")) {
					_custom_def.level_dir = _dir;
				}
			}
				if (array_length(_custom_def.level_dirs) == 0 && _custom_def.level_dir != "") {
					_custom_def.level_dirs = [_custom_def.level_dir];
				}
				scr_challenges_register(_custom_def, _custom_def.is_custom != true);
				ds_map_destroy(_custom_data);
			}
		}
		_dir = file_find_next();
	}
	file_find_close();

	scr_challenges_sort_order();
}

function scr_challenges_init() {
	if (variable_global_exists("challenge_defs")) {
		if (ds_exists(global.challenge_defs, ds_type_map)) ds_map_destroy(global.challenge_defs);
	}
	if (variable_global_exists("challenge_order")) {
		if (ds_exists(global.challenge_order, ds_type_list)) ds_list_destroy(global.challenge_order);
	}
	if (variable_global_exists("challenge_times")) {
		if (ds_exists(global.challenge_times, ds_type_map)) ds_map_destroy(global.challenge_times);
	}
	if (variable_global_exists("challenge_deaths")) {
		if (ds_exists(global.challenge_deaths, ds_type_map)) ds_map_destroy(global.challenge_deaths);
	}

	global.challenge_defs = ds_map_create();
	global.challenge_order = ds_list_create();
	global.challenge_times = ds_map_create();
	global.challenge_deaths = ds_map_create();
	global.challenge_next_id = 1000;
	global.challenge_base_dir = scr_challenge_get_base_dir();

	scr_challenges_load_defs();
	scr_challenge_sync_from_globals();
}

function scr_challenge_get_def(_id) {
	if (!variable_global_exists("challenge_defs")) return undefined;
	var _key = scr_challenge_key(_id);
	if (ds_map_exists(global.challenge_defs, _key)) {
		return global.challenge_defs[? _key];
	}
	return undefined;
}

function scr_challenge_get_title(_def) {
	if (is_undefined(_def)) return "";
	if (is_string(_def.title_loc) && _def.title_loc != "") return loc(_def.title_loc);
	if (_def.title_text != "") return _def.title_text;
	return "Challenge " + string(_def.id);
}

function scr_challenge_is_unlocked(_def) {
	if (is_undefined(_def)) return false;
	switch (_def.unlock_type) {
	case "world":
		return variable_global_get("world" + string(_def.unlock_value)) == 1;
	case "skin":
		return global.skin[_def.unlock_value] >= 1;
	case "hat":
		return global.hat[_def.unlock_value] >= 0;
	default:
		return true;
	}
}

function scr_challenge_reward_unlocked(_def) {
	if (is_undefined(_def)) return false;
	var _checked = false;
	if (array_length(_def.reward_skins) > 0) {
		_checked = true;
		for (var i = 0; i < array_length(_def.reward_skins); i++) {
			if (global.skin[_def.reward_skins[i]] < 1) return false;
		}
	}
	if (_def.reward_hat >= 0) {
		_checked = true;
		return global.hat[_def.reward_hat] >= _def.reward_hat_state;
	}
	if (_checked) return true;
	if (array_length(_def.bonus_skins) > 0) {
		for (var i = 0; i < array_length(_def.bonus_skins); i++) {
			if (global.skin[_def.bonus_skins[i]] < 1) return false;
		}
		return true;
	}
	return false;
}

function scr_challenge_sync_from_globals() {
	if (!variable_global_exists("challenge_defs")) return;
	var _keys = scr_map_keys(global.challenge_defs);
	for (var i = 0; i < ds_list_size(_keys); i++) {
		var _key = _keys[| i];
		var _def = global.challenge_defs[? _key];
		if (_def.time_var != "") {
			ds_map_replace(global.challenge_times, _key, variable_global_get(_def.time_var));
		} else if (!ds_map_exists(global.challenge_times, _key)) {
			ds_map_add(global.challenge_times, _key, 999999);
		}
		if (_def.deaths_var != "") {
			ds_map_replace(global.challenge_deaths, _key, variable_global_get(_def.deaths_var));
		} else if (!ds_map_exists(global.challenge_deaths, _key)) {
			ds_map_add(global.challenge_deaths, _key, 999999);
		}
	}
	ds_list_destroy(_keys);
}

function scr_challenge_get_time(_id) {
	var _key = scr_challenge_key(_id);
	if (variable_global_exists("challenge_times")) {
		if (ds_map_exists(global.challenge_times, _key)) return global.challenge_times[? _key];
	}
	var _def = scr_challenge_get_def(_id);
	if (!is_undefined(_def) && _def.time_var != "") return variable_global_get(_def.time_var);
	return 999999;
}

function scr_challenge_get_deaths(_id) {
	var _key = scr_challenge_key(_id);
	if (variable_global_exists("challenge_deaths")) {
		if (ds_map_exists(global.challenge_deaths, _key)) return global.challenge_deaths[? _key];
	}
	var _def = scr_challenge_get_def(_id);
	if (!is_undefined(_def) && _def.deaths_var != "") return variable_global_get(_def.deaths_var);
	return 999999;
}

function scr_challenge_set_time(_id, _value) {
	var _key = scr_challenge_key(_id);
	if (variable_global_exists("challenge_times")) {
		ds_map_replace(global.challenge_times, _key, _value);
	}
	var _def = scr_challenge_get_def(_id);
	if (!is_undefined(_def) && _def.time_var != "") {
		variable_global_set(_def.time_var, _value);
	}
}

function scr_challenge_set_deaths(_id, _value) {
	var _key = scr_challenge_key(_id);
	if (variable_global_exists("challenge_deaths")) {
		ds_map_replace(global.challenge_deaths, _key, _value);
	}
	var _def = scr_challenge_get_def(_id);
	if (!is_undefined(_def) && _def.deaths_var != "") {
		variable_global_set(_def.deaths_var, _value);
	}
}

function loadstatschallenge(){
	var _def = scr_challenge_get_def(challenge);
	if (is_undefined(_def)) return;
	if (!scr_challenge_is_unlocked(_def)) return;
	time = scr_challenge_get_time(_def.id);
	deaths = scr_challenge_get_deaths(_def.id);
	medalcheck(time, _def.diamond_time, deaths);
}

function scr_challenge_button_setup(_id) {
	challenge = _id;
	text = "Challenge " + string(_id);
	difficulty = 1;
	diamondtime = 9999;
	time = 9999;
	deaths = 999999;
	locked = 1;
	wincol = c_white;
	medalsprite = 0;
	depth = -10;
	BESTTIME = loc("BEST_TIME") + ": ";
	LEASTDEATHS = loc("LEAST_DEATHS") + ": ";
	alarm[0] = 1;

	var _def = scr_challenge_get_def(_id);
	if (is_undefined(_def)) return;
	challenge = _def.id;
	text = scr_challenge_get_title(_def);
	difficulty = _def.difficulty;
	diamondtime = _def.diamond_time;
	time = 9999;
	deaths = 999999;
	locked = 0;
	if (_def.enabled != 1) {
		locked = 1;
	} else if (!scr_challenge_is_unlocked(_def)) {
		locked = 1;
	}
	wincol = scr_challenge_reward_unlocked(_def) ? c_lime : c_white;
	medalsprite = -1;
	depth = -10;
	loadstatschallenge();
	loadgradechallenge();
	BESTTIME = loc("BEST_TIME") + ": ";
	LEASTDEATHS = loc("LEAST_DEATHS") + ": ";
	alarm[0] = 1;
}

function scr_challenge_button_refresh() {
	var _def = scr_challenge_get_def(challenge);
	if (is_undefined(_def)) return;
	locked = (_def.enabled != 1) || (!scr_challenge_is_unlocked(_def));
	if (locked) return;
	time = scr_challenge_get_time(_def.id);
	deaths = scr_challenge_get_deaths(_def.id);
	medalcheck(time, _def.diamond_time, deaths);
	if (medalsprite = 0) { wincol = $2a9190; }
	if (medalsprite = 1) { wincol = c_silver; }
	if (medalsprite = 2) { wincol = c_yellow; }
	if (medalsprite = 3) { wincol = c_aqua; }
	if (medalsprite = 4) { wincol = c_red; }
	if (medalsprite = 5) { wincol = $534534; }
}

function scr_challenge_play_music(_def) {
	if (_def.music_mode == "leveleditor") {
		var _music_path = "";
		if (variable_global_exists("challenge_level_dir") && global.challenge_level_dir != "") {
			var _base_dir = "";
			if (variable_global_exists("challenge_base_dir")) _base_dir = global.challenge_base_dir;
			if (_base_dir == "") _base_dir = scr_challenge_get_base_dir();
			_music_path = _base_dir + global.challenge_level_dir + "/Music.ogg";
		}
		if (_music_path != "" && file_exists(_music_path)) {
			var _mus = audio_create_stream(_music_path);
			audio_play_sound(_mus, 0, 1);
			audio_sound_gain(_mus, global.musicvolume, 1);
		} else {
			scr_leveleditormusic();
		}
		return;
	}
	if (_def.music != "") {
		var _sound = asset_get_index(_def.music);
		if (_sound != -1) {
			audio_play_sound(_sound, 0, 1);
			audio_sound_gain(_sound, global.musicvolume, 1);
		}
	}
}

	function scr_challenge_prepare_custom_level(_def, _level_dir) {
		var _dir = _def.level_dir;
		if (!is_undefined(_level_dir) && _level_dir != "") _dir = _level_dir;
		global.challenge_level_dir = _dir;
		global.LEMode = 2;
		var _base_dir = "";
		if (variable_global_exists("challenge_base_dir")) _base_dir = global.challenge_base_dir;
		if (_base_dir == "") _base_dir = scr_challenge_get_base_dir();
	_base_dir += _dir + "/";
	if (file_exists(_base_dir + "OtherLevelEditor.sav")) {
		ini_open(_base_dir + "OtherLevelEditor.sav");
		global.LELevelWidthBlocks = ini_read_real("Other LE", "Level Width Blocks", 32);
		global.LELevelHeightBlocks = ini_read_real("Other LE", "Level Height Blocks", 22);
		global.LEDiamondMedalTime = ini_read_real("Other LE", "Diamond Medal Time", 35);
		global.leveleditormusic = ini_read_real("Other LE", "Music", 0);
		ini_close();
	}
	global.DiamondMedalTimeChallenge = global.LEDiamondMedalTime;
	room_set_width(r_challengelevel, global.LELevelWidthBlocks * 32);
	room_set_height(r_challengelevel, 64 + (global.LELevelHeightBlocks * 32));
}

function scr_challenge_start(_id) {
	var _def = scr_challenge_get_def(_id);
	if (is_undefined(_def)) return;
	if (_def.enabled != 1) return;
	if (!scr_challenge_is_unlocked(_def)) return;
	if (_def.demo_blocked == 1 && steam_get_app_id() = 1749610) {
		if !instance_exists(o_demoask) { instance_create(x, y, o_demoask); }
		return;
	}

	global.challenges = 1;
	global.currentchallenge = _def.id;
	global.DiamondMedalTimeChallenge = _def.diamond_time;
	global.workshop = 0;
	global.challenge_custom = (_def.is_custom == true);
		global.challenge_level_dir = "";
		global.challenge_level_index = 0;
		global.challenge_room_index = 0;

		if (array_length(_def.level_dirs) > 0) {
			scr_challenge_prepare_custom_level(_def, _def.level_dirs[0]);
			room_goto(r_challengelevel);
		} else if (array_length(_def.rooms) > 0) {
			var _start_index = 0;
			var _start_room = "";
			for (var i = 0; i < array_length(_def.rooms); i++) {
				if (_def.rooms[i] != "") {
					_start_index = i;
					_start_room = _def.rooms[i];
					break;
				}
			}
			if (_start_room != "") {
				global.challenge_room_index = _start_index;
				room_goto(asset_get_index(_start_room));
			}
		} else if (_def.room != "") {
			room_goto(asset_get_index(_def.room));
		}

		loadhud();
	audio_stop_sound(m_mainmenu);
	scr_challenge_play_music(_def);
}

function scr_challenge_advance() {
	if (global.challenges != 1) return false;
	if (global.workshop == 1) return false;
	var _def = scr_challenge_get_def(global.currentchallenge);
	if (is_undefined(_def)) return false;

	var _has_room_sequence = array_length(_def.rooms) > 0;
	var _has_level_sequence = array_length(_def.level_dirs) > 0;
	if (!_has_room_sequence && !_has_level_sequence) return false;

	if (_has_room_sequence) {
		var _current = -1;
		for (var i = 0; i < array_length(_def.rooms); i++) {
			var _room_name = _def.rooms[i];
			if (_room_name == "") continue;
			if (asset_get_index(_room_name) == room) {
				_current = i;
				break;
			}
		}
		if (_current < 0) {
			_current = 0;
			if (variable_global_exists("challenge_room_index")) _current = global.challenge_room_index;
		}
		var _next = _current + 1;
		if (_next < array_length(_def.rooms)) {
			global.challenge_room_index = _next;
			room_goto(asset_get_index(_def.rooms[_next]));
			return true;
		}
	}

	if (_has_level_sequence) {
		var _current = 0;
		if (variable_global_exists("challenge_level_index")) _current = global.challenge_level_index;
		var _next = _current + 1;
		if (_next < array_length(_def.level_dirs)) {
			global.challenge_level_index = _next;
			scr_challenge_prepare_custom_level(_def, _def.level_dirs[_next]);
			room_goto(r_challengelevel);
			return true;
		}
	}

	var _win_room = _def.win_room;
	if (_win_room == "") _win_room = "r_kaizowin";
	var _win = asset_get_index(_win_room);
	if (_win != -1) {
		room_goto(_win);
		return true;
	}
	return false;
}

function scr_challenge_apply_reward(_def) {
	var _save_skins = false;
	var _save_hats = false;
	if (is_undefined(_def)) return [_save_skins, _save_hats];
	if (global.cheats != 0) return [_save_skins, _save_hats];

	if (_def.reward_credits > 0) {
		global.creditscurrency += floor(_def.reward_credits * global.creditsmultiplier);
	}

	if (array_length(_def.reward_skins) > 0) {
		for (var i = 0; i < array_length(_def.reward_skins); i++) {
			var _skin = _def.reward_skins[i];
			if (_skin >= 0 && global.skin[_skin] < 1) {
				global.skin[_skin] = 1;
				_save_skins = true;
			}
		}
	}

	if (_def.reward_hat >= 0) {
		if (global.hat[_def.reward_hat] < _def.reward_hat_state) {
			global.hat[_def.reward_hat] = _def.reward_hat_state;
			_save_hats = true;
		}
	}

	if (_def.bonus_deaths_max >= 0 && array_length(_def.bonus_skins) > 0) {
		if (global.deaths < _def.bonus_deaths_max) {
			for (var i = 0; i < array_length(_def.bonus_skins); i++) {
				var _bonus = _def.bonus_skins[i];
				if (_bonus >= 0 && global.skin[_bonus] < 1) {
					global.skin[_bonus] = 1;
					_save_skins = true;
				}
			}
		}
	}

	return [_save_skins, _save_hats];
}

function scr_challenge_win_setup() {
	audio_stop_all();
	instance_destroy(o_pausesystem);
	instance_destroy(o_timecounter);
	instance_destroy(o_time);
	instance_destroy(o_fadecontroller);
	instance_destroy(o_deathcounter);
	instance_destroy(o_musicdistortion);
	instance_destroy(o_ammocounter);
	global.challenges = 1;

	var _def = scr_challenge_get_def(global.currentchallenge);
	var _saved = scr_challenge_apply_reward(_def);
	if (_saved[0]) scr_saveskins();
	if (_saved[1]) scr_savehats();

	audio_play_sound(m_goodending, 0, 1);
}

function scr_challenge_spawn_custom_buttons() {
	if (!variable_global_exists("challenge_order")) return;
	if (instance_exists(o_challengebutton)) return;
	var _cols = [192, 512, 832];
	var _start_y = 1216;
	var _col = 0;
	var _row = 0;
	var _count = 0;
	for (var i = 0; i < ds_list_size(global.challenge_order); i++) {
		var _id = global.challenge_order[| i];
		var _def = scr_challenge_get_def(_id);
		if (is_undefined(_def)) continue;
		if (_def.is_custom != true) continue;
		var _inst = instance_create(_cols[_col], _start_y + (_row * 144), o_challengebutton);
		with (_inst) {
			scr_challenge_button_setup(_id);
		}
		_col += 1;
		if (_col >= array_length(_cols)) {
			_col = 0;
			_row += 1;
		}
		_count += 1;
	}
	if (_count > 0) {
		var _last_row = _row;
		if (_col == 0) _last_row -= 1;
		var _last_y = _start_y + (_last_row * 144);
		global.challenge_scroll_max = max(500, _last_y - 572);
	} else {
		global.challenge_scroll_max = 500;
	}
}
