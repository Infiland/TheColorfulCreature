/// @description Initialize custom levels browser

depth = -25000

// Tab state: 0=Subscribed, 1=Browse Workshop
tab = 0

// Smooth scroll (newsviewer pattern)
scroll = 0
scroll_target = 0
scroll_max = 0
overlay_alpha = 0

// Grid layout constants for 1024x768
grid_cols = 3
tile_w = 290
tile_h = 200
grid_margin_x = 56
grid_gap = 12
grid_top_y = 140
grid_bottom_y = 720

// Subscribed levels (array of structs)
levels = []
levels_count = 0

// Browse tab state
browse_levels = []
browse_count = 0
browse_state = "idle"
browse_seq = 0 // bumped by every query: only the latest answer is used
browse_deadline = 0
browse_search_text = ""
editing_search = false
browse_page = 1
browse_total = 0

// Owner names are not announced: they are looked up again from Step every 30 frames
owner_name_timer = 0

// Download state poll timer
download_poll_timer = 0

// Hover tracking
hover_index = -1

// Lazy thumbnail loading queue
thumb_queue = []
thumb_loading = false

// Difficulty and featured flag from the comma separated tags of a Workshop item
apply_level_tags = function(_lvl, _tags) {
	var _text = string(_tags)
	if string_count("Easy", _text) > 0 { _lvl.difficulty = 1 }
	if string_count("Medium", _text) > 0 { _lvl.difficulty = 2 }
	if string_count("Difficult", _text) > 0 { _lvl.difficulty = 3 }
	if string_count("Insane", _text) > 0 { _lvl.difficulty = 4 }
	if string_count("Unfair", _text) > 0 { _lvl.difficulty = 5 }
	if string_count("Impossible", _text) > 0 { _lvl.difficulty = 6 }
	if string_count("Level of the Week", _text) > 0 { _lvl.featured = true }
}

// Browse query method (bound to this instance)
send_browse_query = function() {
	browse_state = "loading"
	browse_seq += 1
	browse_deadline = current_time + 20000
	var qh = tcc_steam_ugc_create_query_all(SteamUgcQuery.RankedByVote, SteamUgcMatchingUgcType.Items, browse_page)
	if !tcc_steam_ugc_handle_valid(qh) {
		browse_state = "error"
		return
	}
	if browse_search_text != "" {
		tcc_steam_ugc_query_set_search_text(qh, browse_search_text)
	}
	// An answer for an older query carries an older seq and is ignored
	var _on_result = method({inst: id, seq: browse_seq}, function(_ok, _items, _completed) {
		if !instance_exists(inst) || inst.browse_seq != seq { return }
		if !_ok {
			inst.browse_state = "error"
			return
		}
		with (inst) {
			browse_total = _completed.total_matching_results

			if browse_page = 1 {
				browse_levels = []
				browse_count = 0
			}

			for (var i = 0; i < array_length(_items); i++) {
				var _item = _items[i]

				var lvl = {}
				lvl.file_id = _item.published_file_id
				lvl.path = ""
				lvl.title = _item.title
				lvl.owner_name = "Unknown"
				lvl.owner_id = _item.owner_steam_id
				lvl.likes = _item.votes_up
				lvl.dislikes = _item.votes_down
				lvl.tags = ""
				lvl.difficulty = 0
				lvl.banned = (_item.banned == true)
				lvl.featured = false
				lvl.loaded = true
				lvl.thumb_spr = -1
				lvl.thumb_checked = true
				lvl.thumb_handle = _item.handle_preview_file // UGC handle for preview download
				lvl.thumb_downloading = false
				lvl.medal_time = 9999999
				lvl.medal_required = 999999
				lvl.download_state = "unknown"

				apply_level_tags(lvl, _item.tags)

				// Check if already subscribed/installed
				var info = ds_map_create()
				tcc_steam_ugc_get_item_update_info(lvl.file_id, info)
				if info[? "is_installed"] = 1 { lvl.download_state = "installed" }
				else if info[? "is_downloading"] = 1 { lvl.download_state = "downloading" }
				else if info[? "is_download_pending"] = 1 { lvl.download_state = "pending" }
				else { lvl.download_state = "not_installed" }
				ds_map_destroy(info)

				browse_levels[browse_count] = lvl
				browse_count++
			}

			browse_state = "loaded"
		}
	})
	if !tcc_steam_ugc_send_query(qh, _on_result, id) {
		browse_state = "error"
	}
}

// Populate subscribed levels (NO thumbnail loading here - done lazily in draw)
if global.steam_api = true {
	var steam_list = ds_list_create()
	tcc_steam_ugc_get_subscribed_items(steam_list)

	var detail_ids = []
	var j = 0
	for (var i = 0; i < ds_list_size(steam_list); i++) {
		var file_id = steam_list[| i]
		var file_info = ds_map_create()
		tcc_steam_ugc_get_item_install_info(file_id, file_info)
		var path_to_file = file_info[? "folder"]
		ds_map_destroy(file_info)

		var path_norm = string_replace_all(string(path_to_file), "\\", "/")
		if (string_copy(path_norm, string_length(path_norm), 1) != "/") { path_norm += "/" }
		if !level_exists(path_norm) { continue }

		// Build level struct
		var lvl = {}
		lvl.file_id = file_id
		lvl.path = path_norm
		lvl.title = "Loading..."
		lvl.owner_name = "Unknown"
		lvl.owner_id = 0
		lvl.likes = 0
		lvl.dislikes = 0
		lvl.tags = ""
		lvl.difficulty = 0
		lvl.banned = false
		lvl.featured = false
		lvl.loaded = false
		lvl.thumb_spr = -1
		lvl.thumb_checked = false // lazy loading flag
		lvl.medal_time = 9999999
		lvl.medal_required = 999999
		lvl.download_state = "unknown"

		var _metadata = level_metadata(path_norm);
        if (is_undefined(_metadata)) continue;
        lvl.medal_required = _metadata.diamondTime;

		// Load medal progress
		var medal_dir = directory_set("/Custom/Workshop/Medals/" + string(file_id) + "/")
		if !directory_exists(medal_dir) { directory_create(medal_dir) }
		if file_exists(medal_dir + "MedalData.sav") {
			ini_open(medal_dir + "MedalData.sav")
			lvl.medal_time = ini_read_real("Medal Data", "Time", 9999999)
			lvl.medal_required = ini_read_real("Medal Data", "Required Time", lvl.medal_required)
			ini_close()
		}

		// Check download state
		var info = ds_map_create()
		tcc_steam_ugc_get_item_update_info(file_id, info)
		if info[? "is_installed"] = 1 { lvl.download_state = "installed" }
		else if info[? "is_downloading"] = 1 { lvl.download_state = "downloading" }
		else if info[? "is_download_pending"] = 1 { lvl.download_state = "pending" }
		else { lvl.download_state = "not_installed" }
		ds_map_destroy(info)

		// Steam details are requested for all levels together after the loop
		array_push(detail_ids, file_id)

		levels[j] = lvl
		j++
	}

	levels_count = j
	ds_list_destroy(steam_list)

	// One details request for every subscribed level (async). The answer arrives in chunks and
	// is matched by file id; the owner name is looked up later from Step.
	if array_length(detail_ids) > 0 {
		tcc_steam_ugc_request_item_details(detail_ids, 30, method({inst: id}, function(_ok, _items, _completed) {
			if !_ok || !instance_exists(inst) { return }
			with (inst) {
				for (var n = 0; n < array_length(_items); n++) {
					var _item = _items[n]
					for (var m = 0; m < levels_count; m++) {
						var _lvl = levels[m]
						if _lvl.file_id != _item.published_file_id { continue }
						_lvl.title = _item.title
						_lvl.owner_id = _item.owner_steam_id
						_lvl.likes = _item.votes_up
						_lvl.dislikes = _item.votes_down
						_lvl.banned = (_item.banned == true)
						_lvl.loaded = true
						apply_level_tags(_lvl, _item.tags)
						break
					}
				}
			}
		}), id)
	}

	// Calculate scroll max
	var total_rows = ceil(real(levels_count) / grid_cols)
	var visible_rows = floor((grid_bottom_y - grid_top_y) / (tile_h + grid_gap))
	if total_rows > visible_rows {
		scroll_max = (total_rows - visible_rows) * (tile_h + grid_gap)
	}
}
