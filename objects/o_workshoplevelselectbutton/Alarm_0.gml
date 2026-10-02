if (!timing_is_tick()) exit;
if level = 0 {
	alarm[0] = 10
	exit
}

steam_details = tcc_steam_ugc_request_item_details(level, 30);

// Read diamond time from installed workshop level metadata
if (mPath != "") {
	var dir = string_replace_all(string(mPath),"\\","/")
	if (string_copy(dir, string_length(dir), 1) != "/") { dir += "/" }
	mPath = dir
    var _metadata = level_metadata(dir);
    if (!is_undefined(_metadata)) diamond_time = _metadata.diamondTime;

	// Load thumbnail image
	if (thumb_spr == -1) {
		if (file_exists(dir + "thumb.jpg")) {
			thumb_spr = sprite_add(dir + "thumb.jpg", 0, false, false, 0, 0);
			thumb_loaded = 1;
		} else if (file_exists(dir + "thumb.png")) {
			thumb_spr = sprite_add(dir + "thumb.png", 0, false, false, 0, 0);
			thumb_loaded = 1;
		}
	}
}

alarm[0] = -1
