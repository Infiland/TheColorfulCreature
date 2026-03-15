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
	global.workshopchallenge = 0
	global.workshopchallenge_title = ""
	global.workshopchallenge_levels = []
	global.workshopchallenge_index = 0
	global.workshopchallenge_diamond_time = 0
	global.workshopchallenge_difficulty = 0
	global.workshopchallenge_signature = ""
	global.workshopchallenge_is_draft = 0
	global.workshopfolder = ""
	global.workshop = 0
	global.challenges = 0
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
	}

	global.levelname = global.workshopchallenge_title
	room_goto(r_workshoplevelwin)
}

function scr_workshopchallenge_goto_level(_index) {
	if (!variable_global_exists("workshopchallenge") || global.workshopchallenge != 1) return;
	if (_index < 0 || _index >= array_length(global.workshopchallenge_levels)) return;
	if (!global.steam_api) return;

	var _level = global.workshopchallenge_levels[_index];
	var _level_id = _level;
	var _level_title = "Workshop Level";
	if (is_struct(_level)) {
		if (variable_struct_exists(_level, "id")) _level_id = _level.id;
		if (variable_struct_exists(_level, "title")) _level_title = _level.title;
	}

	var _info = ds_map_create();
	steam_ugc_get_item_install_info(_level_id, _info);
	var _folder = "";
	if (ds_map_exists(_info, "folder")) _folder = _info[? "folder"];
	ds_map_destroy(_info);

	_folder = string_replace_all(string(_folder), "\\", "/");
	if (_folder == "") {
		if !instance_exists(o_popup) {
			global.popup_config = {
				title: "Workshop Challenge",
				message: "Missing subscribed workshop level:\n" + string(_level_id),
				mode: 0
			}
			instance_create(0, 0, o_popup)
		}
		scr_workshopchallenge_abort();
		return;
	}
	if (string_copy(_folder, string_length(_folder), 1) != "/") _folder += "/"

	global.workshopfolder = _folder
	global.Publish_ID = _level_id
	global.levelname = _level_title

	// Resize room based on workshop level metadata
	if (file_exists(_folder + "OtherLevelEditor.sav")) {
		ini_open(_folder + "OtherLevelEditor.sav");
		global.LELevelWidthBlocks = ini_read_real("Other LE","Level Width Blocks",32);
		global.LELevelHeightBlocks = ini_read_real("Other LE","Level Height Blocks",22);
		ini_close();
	}
	room_set_width(r_customlevelworkshop,global.LELevelWidthBlocks*32)
	room_set_height(r_customlevelworkshop,64+(global.LELevelHeightBlocks*32))

	loadhud()
	if !instance_exists(o_narrator) { instance_create(0,0,o_narrator) }
	instance_destroy(o_coincounter)

	room_goto(r_customlevelworkshop)
}

function scr_workshopchallenge_start(_challenge) {
	if (!global.steam_api) return;
	if (is_undefined(_challenge)) return;
	if (!is_struct(_challenge)) return;
	if (!variable_struct_exists(_challenge, "levels")) return;
	if (!is_array(_challenge.levels) || array_length(_challenge.levels) <= 0) return;

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
