if (mPath == "") {
	alarm[0] = 10
	exit
}

var dir = string_replace_all(string(mPath),"\\","/")
if (string_copy(dir, string_length(dir), 1) != "/") { dir += "/" }
mPath = dir

if !file_exists(dir + "challenge.json") {
	title = "Invalid challenge"
	invalid = 1
	loaded = 1
	exit
}

var data = LoadJSONFromFile(dir + "challenge.json")
if (ds_map_exists(data, "type") && data[? "type"] != "workshop_challenge") {
	title = "Invalid challenge"
	invalid = 1
	loaded = 1
	ds_map_destroy(data)
	exit
}

title = ds_map_exists(data, "title") ? data[? "title"] : "Workshop Challenge"
diamond_time = ds_map_exists(data, "diamond_time") ? data[? "diamond_time"] : 0
difficulty = ds_map_exists(data, "difficulty") ? data[? "difficulty"] : 0

level_count = 0
var _levels_for_validation = []
if (ds_map_exists(data, "levels")) {
	var levels = data[? "levels"]
	if (ds_exists(levels, ds_type_list)) {
		level_count = ds_list_size(levels)
		// Build levels array for validation without re-parsing JSON
		for (var _vi = 0; _vi < level_count; _vi++) {
			var _entry = levels[| _vi];
			var _lvl = {};
			if (ds_exists(_entry, ds_type_map)) {
				_lvl.id = ds_map_exists(_entry, "id") ? _entry[? "id"] : 0;
				_lvl.title = ds_map_exists(_entry, "title") ? _entry[? "title"] : "Workshop Level";
			} else {
				_lvl.id = _entry;
				_lvl.title = "Workshop Level";
			}
			_levels_for_validation[_vi] = _lvl;
		}
	}
}

loaded = 1
ds_map_destroy(data)

// Pre-validate that all levels are subscribed
if (array_length(_levels_for_validation) > 0) {
	var _temp_challenge = { levels: _levels_for_validation };
	var _validation = scr_workshopchallenge_validate_levels(_temp_challenge)
	if (!_validation.valid) {
		missing_levels = array_length(_validation.missing)
	}
}

