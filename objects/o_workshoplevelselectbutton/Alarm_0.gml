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
}

alarm[0] = -1
