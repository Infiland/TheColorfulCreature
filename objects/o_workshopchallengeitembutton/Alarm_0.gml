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
if (ds_map_exists(data, "levels")) {
	var levels = data[? "levels"]
	if (ds_exists(levels, ds_type_list)) level_count = ds_list_size(levels)
}

loaded = 1
ds_map_destroy(data)

