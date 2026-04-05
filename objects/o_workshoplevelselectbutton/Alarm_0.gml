if level = 0 {
	alarm[0] = 10
	exit
}

steam_details = steam_ugc_request_item_details(level, 30);

// Read diamond time from installed workshop level metadata
if (mPath != "") {
	var dir = string_replace_all(string(mPath),"\\","/")
	if (string_copy(dir, string_length(dir), 1) != "/") { dir += "/" }
	mPath = dir
	if (file_exists(dir + "OtherLevelEditor.sav")) {
		ini_open(dir + "OtherLevelEditor.sav");
		diamond_time = ini_read_real("Other LE","Diamond Medal Time",0);
		ini_close();
	}

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
