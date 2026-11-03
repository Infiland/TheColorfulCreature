depth = -25000

if !instance_exists(o_workshopchallengecreatorbg) {
	instance_create(0,0,o_workshopchallengecreatorbg)
}

L = scr_workshopchallenge_layout()

editing = 0 // 0 = none, 1 = title field, 2 = search field
title = string(global.workshopchallenge_draft_title)
search = ""
keyboard_string = ""

filter_mode = 0 // 0 = subscribed, 1 = my levels
level_buttons = []
selection = [] // picked level tiles, in play order
draft_ids = [] // level ids of the selection, kept for CleanUp

seq_first = 0 // first visible row of the sequence list
sb_drag = 0
sb_drag_off = 0
sb_thumb_y = 0
sb_thumb_h = 0
input_hold = 3 // ignore input for a few ticks so the click that opened us is not reused

selected_count = 0
diamond_sum = 0
difficulty_avg = 0
signature_current = ""
total_count = 0
visible_count = 0
owned_count = 0
unloaded_count = 0
all_shown_picked = 0
ok_title = 0
ok_levels = 0
ok_cheats = 1
ok_beaten = 0

hot = ""
hot_i = -1
hot_j = -1
hover_tile = noone
hv = { close: 0, tab0: 0, tab1: 0, search: 0, selall: 0, title: 0, clear: 0, play: 0, upload: 0 }

global.workshopchallenge_scroll = 0
global.workshopchallenge_scrollmax = 0

// Spawn subscribed workshop levels to pick from
steam_list = ds_list_create();
tcc_steam_ugc_get_subscribed_items(steam_list);

var j = 0
for (var i = 0; i < ds_list_size(steam_list); i++) {
	var file_id = steam_list[| i];
	var file_info = ds_map_create();
	tcc_steam_ugc_get_item_install_info(file_id, file_info);
	var path_to_file = file_info[? "folder"];
	ds_map_destroy(file_info);

	var path_norm = string_replace_all(string(path_to_file),"\\","/");
	if (string_copy(path_norm, string_length(path_norm), 1) != "/") { path_norm += "/" }
	if !level_exists(path_norm) { continue; }

	// Position, visibility and selection are driven by the Step event
	var button = instance_create(L.list[0], L.list[1], o_workshoplevelselectbutton)
	level_buttons[j] = button
	with(button) {
		level = file_id
		mPath = path_norm
	}
	j += 1
}

ds_list_destroy(steam_list)

// Restore the previous draft, keeping its level order
var preselect = global.workshopchallenge_draft_level_ids
if (is_array(preselect)) {
	for (var k = 0; k < array_length(preselect); k++) {
		for (var m = 0; m < array_length(level_buttons); m++) {
			if (level_buttons[m].level == preselect[k]) {
				array_push(selection, level_buttons[m])
				array_push(draft_ids, preselect[k])
				break
			}
		}
	}
}
