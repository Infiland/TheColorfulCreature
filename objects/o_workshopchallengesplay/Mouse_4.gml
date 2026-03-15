if instance_exists(o_workshopchallengeitembutton) { exit }
if global.steam_api = true {
	if !instance_exists(o_showsubscribedchallenges) {
		instance_create(x,y,o_showsubscribedchallenges)
	}

	global.workshopchallenges_scroll = 0
	global.workshopchallenges_scrollmax = 0

	steam_list = ds_list_create();
	steam_ugc_get_subscribed_items(steam_list);

	var j = 0
	for (var i = 0; i < ds_list_size(steam_list); i++) {
		var file_id = steam_list[| i];
		var file_info = ds_map_create();
		steam_ugc_get_item_install_info(file_id, file_info);
		var path_to_file = file_info[? "folder"];
		ds_map_destroy(file_info);

		var path_norm = string_replace_all(string(path_to_file),"\\","/");
		if (string_copy(path_norm, string_length(path_norm), 1) != "/") { path_norm += "/" }
		if !file_exists(path_norm + "challenge.json") { continue; }

		var button = instance_create((room_width/2)-100,150 + (j* 95), o_workshopchallengeitembutton)
		with(button) {
			item_id = file_id
			mPath = path_norm
		}
		if j > 5 { global.workshopchallenges_scrollmax += 95 }
		j += 1
	}

	ds_list_destroy(steam_list)
}
