depth = -25000

if !instance_exists(o_workshopchallengecreatorbg) {
	instance_create(0,0,o_workshopchallengecreatorbg)
}

editing_title = 0
title = global.workshopchallenge_draft_title
keyboard_string = ""

selected_count = 0
diamond_sum = 0
difficulty_avg = 0
signature_current = ""

filter_mode = 0 // 0 = subscribed, 1 = my levels
level_buttons = []

global.workshopchallenge_scroll = 0
global.workshopchallenge_scrollmax = 0

// Spawn subscribed workshop levels to pick from
steam_list = ds_list_create();
steam_ugc_get_subscribed_items(steam_list);

var preselect = global.workshopchallenge_draft_level_ids
var j = 0
for (var i = 0; i < ds_list_size(steam_list); i++) {
	var file_id = steam_list[| i];
	var file_info = ds_map_create();
	steam_ugc_get_item_install_info(file_id, file_info);
	var path_to_file = file_info[? "folder"];
	ds_map_destroy(file_info);

	var path_norm = string_replace_all(string(path_to_file),"\\","/");
	if (string_copy(path_norm, string_length(path_norm), 1) != "/") { path_norm += "/" }
	if !file_exists(path_norm + "LevelEditor.sav") { continue; }

	var is_selected = 0
	if (is_array(preselect)) {
		for (var k = 0; k < array_length(preselect); k++) {
			if preselect[k] == file_id { is_selected = 1 break; }
		}
	}

	var button = instance_create((room_width/2)-100,320 + (j* 95), o_workshoplevelselectbutton)
	level_buttons[j] = button
	with(button) {
		level = file_id
		mPath = path_norm
		selected = is_selected
	}
	if j > 3 { global.workshopchallenge_scrollmax += 95 }
	j += 1
}

ds_list_destroy(steam_list)

// UI buttons (custom style)
var btn_sub = instance_create(160, 260, o_workshopchallengecreatorbutton)
with (btn_sub) {
	creator = other.id
	kind = 0
	text = "Subscribed"
	image_xscale = 66
	image_yscale = 6
}

var btn_my = instance_create(534, 260, o_workshopchallengecreatorbutton)
with (btn_my) {
	creator = other.id
	kind = 1
	text = "My Levels"
	image_xscale = 66
	image_yscale = 6
}

var btn_play = instance_create(140, 680, o_workshopchallengecreatorbutton)
with (btn_play) {
	creator = other.id
	kind = 2
	text = "Play Challenge"
	image_xscale = 60
	image_yscale = 12
}

var btn_upload = instance_create(584, 680, o_workshopchallengecreatorbutton)
with (btn_upload) {
	creator = other.id
	kind = 3
	text = "Upload\nChallenge"
	image_xscale = 60
	image_yscale = 12
}
