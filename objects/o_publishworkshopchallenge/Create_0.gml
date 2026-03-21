depth = -21000

result = 0
timer = 0

published_file_id = 0
create_request = 0
submit_request = 0
update_handle = 0

content_dir = ""
preview_path = ""
challenge_title = ""
challenge_desc = ""

if !global.steam_api {
	result = 3
	timer = 600
	exit
}
if steam_is_user_logged_on() = false {
	result = 3
	timer = 600
	exit
}
if is_undefined(global.workshopchallenge_draft) || !is_struct(global.workshopchallenge_draft) {
	result = 4
	timer = 600
	exit
}

var draft = global.workshopchallenge_draft
challenge_title = variable_struct_exists(draft, "title") ? draft.title : "Workshop Challenge"

// Build safe folder name
var safe = string(challenge_title)
safe = string_replace_all(safe, "\\", "_")
safe = string_replace_all(safe, "/", "_")
safe = string_replace_all(safe, ":", "_")
safe = string_replace_all(safe, "*", "_")
safe = string_replace_all(safe, "?", "_")
safe = string_replace_all(safe, "\"", "_")
safe = string_replace_all(safe, "<", "_")
safe = string_replace_all(safe, ">", "_")
safe = string_replace_all(safe, "|", "_")
if string_length(safe) > 40 { safe = string_copy(safe, 1, 40) }
if safe == "" { safe = "WorkshopChallenge" }

content_dir = directory_set("/Workshop Challenges/" + safe + "/")
if !directory_exists(content_dir) { directory_create(content_dir) }

// Write challenge.json
var wrapper = ds_map_create();
ds_map_add(wrapper, "format", 1);
ds_map_add(wrapper, "type", "workshop_challenge");
ds_map_add(wrapper, "title", challenge_title);
ds_map_add(wrapper, "diamond_time", variable_struct_exists(draft, "diamond_time") ? draft.diamond_time : 0);
ds_map_add(wrapper, "difficulty", variable_struct_exists(draft, "difficulty") ? draft.difficulty : 0);

var lvl_list = ds_list_create();
if (variable_struct_exists(draft, "levels") && is_array(draft.levels)) {
	for (var i = 0; i < array_length(draft.levels); i++) {
		var lvl = draft.levels[i];
		var m = ds_map_create();
		ds_map_add(m, "id", variable_struct_exists(lvl, "id") ? lvl.id : 0);
		ds_map_add(m, "title", variable_struct_exists(lvl, "title") ? lvl.title : "Workshop Level");
		ds_map_add(m, "diamond_time", variable_struct_exists(lvl, "diamond_time") ? lvl.diamond_time : 0);
		ds_map_add(m, "difficulty", variable_struct_exists(lvl, "difficulty") ? lvl.difficulty : 0);
		ds_list_add(lvl_list, m);
		ds_list_mark_as_map(lvl_list, i);
	}
}
ds_map_add_list(wrapper, "levels", lvl_list);

SaveStringToFile(content_dir + "challenge.json", json_encode(wrapper))

// Cleanup DS — wrapper owns the list and its sub-maps via mark_as_map
ds_map_destroy(wrapper)

// Auto-generate preview image using first level's thumbnail
preview_path = content_dir + "preview.png"
var _thumb_spr = -1;
var _thumb_folder = "";

// Try to get the first level's thumbnail
if (variable_struct_exists(draft, "levels") && is_array(draft.levels) && array_length(draft.levels) > 0) {
	var _first_level = draft.levels[0];
	var _first_id = variable_struct_exists(_first_level, "id") ? _first_level.id : 0;
	if (_first_id != 0 && global.steam_api) {
		var _info = ds_map_create();
		steam_ugc_get_item_install_info(_first_id, _info);
		if (ds_map_exists(_info, "folder")) {
			_thumb_folder = string_replace_all(string(_info[? "folder"]), "\\", "/");
			if (_thumb_folder != "" && string_copy(_thumb_folder, string_length(_thumb_folder), 1) != "/") _thumb_folder += "/";
		}
		ds_map_destroy(_info);
	}

	// Try loading thumb.jpg from the first level's folder
	if (_thumb_folder != "") {
		if (file_exists(_thumb_folder + "thumb.jpg")) {
			_thumb_spr = sprite_add(_thumb_folder + "thumb.jpg", 0, false, false, 0, 0);
		} else if (file_exists(_thumb_folder + "thumb.png")) {
			_thumb_spr = sprite_add(_thumb_folder + "thumb.png", 0, false, false, 0, 0);
		}
	}
}

var surf = surface_create(512, 512);
if (surface_exists(surf)) {
	surface_set_target(surf);
	draw_clear_alpha(c_black, 1);

	// Draw first level thumbnail as background
	if (_thumb_spr != -1) {
		var _sw = sprite_get_width(_thumb_spr);
		var _sh = sprite_get_height(_thumb_spr);
		var _scale = max(512 / _sw, 512 / _sh);
		var _dx = (512 - _sw * _scale) / 2;
		var _dy = (512 - _sh * _scale) / 2;
		draw_sprite_ext(_thumb_spr, 0, _dx, _dy, _scale, _scale, 0, c_white, 1);
	}

	// Semi-transparent overlay bar at bottom
	draw_set_alpha(0.7);
	draw_set_color(c_black);
	draw_rectangle(0, 350, 512, 512, false);
	draw_set_alpha(1);

	// Challenge title
	draw_set_color(c_white);
	draw_set_font(fnt_mainmenu);
	draw_set_halign(fa_center);
	draw_set_valign(fa_top);
	draw_text_ext(256, 370, challenge_title, 32, 480);

	// Level count and diamond time
	draw_set_font(global.deathfont);
	var _level_count = 0;
	if (variable_struct_exists(draft, "levels") && is_array(draft.levels)) _level_count = array_length(draft.levels);
	var _diamond = variable_struct_exists(draft, "diamond_time") ? draft.diamond_time : 0;
	draw_text(256, 430, string(_level_count) + " levels | Diamond: " + string(_diamond) + "s");

	// "Workshop Challenge" label
	draw_text(256, 470, "Workshop Challenge");

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	surface_reset_target();
	surface_save(surf, preview_path);
	surface_free(surf);
}

// Cleanup thumbnail sprite
if (_thumb_spr != -1) {
	sprite_delete(_thumb_spr);
}

// Description (auto)
var levels_arr = []
if (variable_struct_exists(draft, "levels") && is_array(draft.levels)) { levels_arr = draft.levels }
var diamond_total = variable_struct_exists(draft, "diamond_time") ? draft.diamond_time : 0
var difficulty_avg = variable_struct_exists(draft, "difficulty") ? draft.difficulty : 0

challenge_desc = "A workshop challenge containing " + string(array_length(levels_arr)) + " levels.\n"
challenge_desc += "Total diamond time: " + string(diamond_total) + "s\n"
challenge_desc += "Average difficulty: " + string(difficulty_avg) + "\n\nLevels:\n"
for (var i = 0; i < array_length(levels_arr); i++) {
	var lvl = levels_arr[i];
	var lvl_title = variable_struct_exists(lvl, "title") ? lvl.title : "Workshop Level"
	var lvl_id = variable_struct_exists(lvl, "id") ? lvl.id : 0
	challenge_desc += "- " + string(lvl_title) + " (" + string(lvl_id) + ")\n"
}

// Create workshop item
create_request = steam_ugc_create_item(global.appid, ugc_filetype_community);
result = 0.1
