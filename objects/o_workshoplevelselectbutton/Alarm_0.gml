if (!timing_is_tick()) exit;
if level = 0 {
	alarm[0] = 10
	exit
}

// Ask Steam for the details of this level; the callback applies the answer
tcc_steam_ugc_request_item_details(level, 30, method({inst: id}, function(_ok, _items, _completed) {
	if !_ok || !instance_exists(inst) { return }
	for (var i = 0; i < array_length(_items); i++) {
		var _item = _items[i]
		if _item.published_file_id != inst.level { continue }
		with (inst) {
			mTitle = _item.title
			mTags = _item.tags
			owner_id = _item.owner_steam_id
			loaded = 1

			var easy = string_count("Easy", string(mTags));
			var medium = string_count("Medium", string(mTags));
			var difficult = string_count("Difficult", string(mTags));
			var insane = string_count("Insane", string(mTags));
			var unfair = string_count("Unfair", string(mTags));
			var impossible = string_count("Impossible", string(mTags));

			difficulty = 0
			if easy = 1 { difficulty = 1 }
			if medium = 1 { difficulty = 2 }
			if difficult = 1 { difficulty = 3 }
			if insane = 1 { difficulty = 4 }
			if unfair = 1 { difficulty = 5 }
			if impossible = 1 { difficulty = 6 }
		}
		break
	}
}), id);

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
