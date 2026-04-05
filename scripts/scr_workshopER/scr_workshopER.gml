/// @description Workshop Endless Run (Mode 4) core functions

/// Builds the level pool from subscribed workshop items
/// Returns true if pool has at least 1 level
function workshopER_build_pool() {
	global.workshopER_pool = []
	global.workshopER_pool_count = 0
	global.workshopER_auto_subscribed = []

	if !global.steam_api { return false }

	var steam_list = ds_list_create()
	steam_ugc_get_subscribed_items(steam_list)

	var j = 0
	for (var i = 0; i < ds_list_size(steam_list); i++) {
		var file_id = steam_list[| i]
		var file_info = ds_map_create()
		steam_ugc_get_item_install_info(file_id, file_info)
		var path_to_file = file_info[? "folder"]
		ds_map_destroy(file_info)

		var path_norm = string_replace_all(string(path_to_file), "\\", "/")
		if (string_copy(path_norm, string_length(path_norm), 1) != "/") { path_norm += "/" }
		if !file_exists(path_norm + "LevelEditor.sav") { continue }

		var lvl = {}
		lvl.file_id = file_id
		lvl.path = path_norm
		lvl.was_auto_subscribed = false

		global.workshopER_pool[j] = lvl
		j++
	}

	global.workshopER_pool_count = j
	ds_list_destroy(steam_list)
	return (global.workshopER_pool_count > 0)
}

/// Called from the menu button to start a Workshop Endless Run
function workshopER_start() {
	var has_levels = workshopER_build_pool()

	if !has_levels {
		if !instance_exists(o_popup) {
			global.popup_config = {
				title: loc("WORKSHOP_ENDLESS_RUN"),
				message: loc("WORKSHOP_ER_NO_LEVELS"),
				mode: 0
			}
			instance_create(0, 0, o_popup)
		}
		global.endless = 0
		global.workshop = 0
		global.endlessrunmode = 0
		hidehud()
		return
	}

	// Create persistent async handler (also acts as loading screen when downloading)
	if !instance_exists(o_workshopERloading) {
		instance_create(0, 0, o_workshopERloading)
	}

	// Start background catalog scan for non-subscribed levels
	global.workshopER_catalog_scan_done = false
	global.workshopER_catalog_ids = []
	global.workshopER_query_page = 1
	workshopER_query_catalog()

	// Pick and load first level
	workshopERrandomlevel()
}

/// Sends a Steam UGC query page to discover non-subscribed levels
function workshopER_query_catalog() {
	if !global.steam_api { return }
	var qh = steam_ugc_create_query_all(ugc_query_RankedByPublicationDate, ugc_match_Items, global.workshopER_query_page)
	global.workshopER_query_id = steam_ugc_send_query(qh)
}

/// Core level selection for Workshop Endless Run
function workshopERrandomlevel() {
	randomize()

	// Decide: pick from subscribed pool or from catalog (non-subscribed)
	var use_catalog = false
	if global.workshopER_catalog_scan_done && array_length(global.workshopER_catalog_ids) > 0 {
		if global.workshopER_pool_count < 3 {
			use_catalog = true
		} else {
			use_catalog = (irandom(4) == 0) // 20% chance
		}
	}

	if use_catalog {
		workshopER_pick_catalog_level()
	} else {
		workshopER_pick_pool_level()
	}

	// 1-up logic
	global.endless1upchange -= 1
	if global.endless1upchange < 1 {
		if global.infinitelivessettings = 0 {
			global.hardmodelives += 1
			global.endless1upchange = 10
		}
	}
}

/// Picks a random level from the subscribed pool
function workshopER_pick_pool_level() {
	if global.workshopER_pool_count = 0 {
		// No pool levels, try catalog
		if array_length(global.workshopER_catalog_ids) > 0 {
			workshopER_pick_catalog_level()
		} else {
			workshopER_game_over()
		}
		return
	}

	var idx = irandom(global.workshopER_pool_count - 1)
	var attempts = 0

	// Avoid same level twice in a row
	while (global.workshopER_pool[idx].file_id == global.workshopER_last_file_id && global.workshopER_pool_count > 1 && attempts < 10) {
		idx = irandom(global.workshopER_pool_count - 1)
		attempts++
	}

	var lvl = global.workshopER_pool[idx]
	global.workshopER_current_file_id = lvl.file_id
	global.workshopER_last_file_id = lvl.file_id

	workshopER_goto_level(lvl.file_id)
}

/// Picks a random level from the non-subscribed catalog, triggers subscribe+download
function workshopER_pick_catalog_level() {
	var catalog = global.workshopER_catalog_ids
	if array_length(catalog) == 0 {
		workshopER_pick_pool_level()
		return
	}

	var idx = irandom(array_length(catalog) - 1)
	var file_id = catalog[idx]
	var attempts = 0

	// Avoid same level
	while (file_id == global.workshopER_last_file_id && array_length(catalog) > 1 && attempts < 10) {
		idx = irandom(array_length(catalog) - 1)
		file_id = catalog[idx]
		attempts++
	}

	// Check if already installed
	var info = ds_map_create()
	steam_ugc_get_item_install_info(file_id, info)
	var folder = ""
	if ds_map_exists(info, "folder") { folder = info[? "folder"] }
	ds_map_destroy(info)

	folder = string_replace_all(string(folder), "\\", "/")
	if (string_copy(folder, string_length(folder), 1) != "/") { folder += "/" }

	if folder != "/" && file_exists(folder + "LevelEditor.sav") {
		// Already available locally
		global.workshopER_current_file_id = file_id
		global.workshopER_last_file_id = file_id
		workshopER_goto_level(file_id)
		return
	}

	// Need to subscribe and download
	steam_ugc_subscribe_item(file_id)
	array_push(global.workshopER_auto_subscribed, file_id)

	global.workshopER_current_file_id = file_id
	global.workshopER_last_file_id = file_id
	global.workshopER_loading = true

	// Switch persistent loading instance to waiting state
	if instance_exists(o_workshopERloading) {
		with (o_workshopERloading) {
			target_file_id = file_id
			state = "waiting"
			wait_frames = 0
			poll_timer = 0
			dots = 0
			dot_timer = 0
		}
	}
}

/// Loads a workshop level into r_customlevelworkshop
/// Pattern from scr_workshopchallenge_goto_level()
function workshopER_goto_level(_file_id) {
	if !global.steam_api { return }

	var _info = ds_map_create()
	steam_ugc_get_item_install_info(_file_id, _info)
	var _folder = ""
	if ds_map_exists(_info, "folder") { _folder = _info[? "folder"] }
	ds_map_destroy(_info)

	_folder = string_replace_all(string(_folder), "\\", "/")
	if (_folder == "") {
		workshopER_skip_level()
		return
	}
	if (string_copy(_folder, string_length(_folder), 1) != "/") _folder += "/"

	if !file_exists(_folder + "LevelEditor.sav") {
		workshopER_skip_level()
		return
	}

	global.workshopfolder = _folder
	global.Publish_ID = _file_id

	// Read metadata for room dimensions and music
	global.LELevelWidthBlocks = 32
	global.LELevelHeightBlocks = 22
	global.leveleditormusic = ""
	global.levelname = ""

	if file_exists(_folder + "OtherLevelEditor.sav") {
		ini_open(_folder + "OtherLevelEditor.sav")
		global.LELevelWidthBlocks = ini_read_real("Other LE", "Level Width Blocks", 32)
		global.LELevelHeightBlocks = ini_read_real("Other LE", "Level Height Blocks", 22)
		global.leveleditormusic = ini_read_string("Other LE", "Music", "")
		global.levelname = ini_read_string("Other LE", "Name", "")
		ini_close()
	}

	// Resize room before goto
	room_set_width(r_customlevelworkshop, global.LELevelWidthBlocks * 32)
	room_set_height(r_customlevelworkshop, 64 + (global.LELevelHeightBlocks * 32))

	// Play music from workshop level metadata
	scr_leveleditormusic()

	// Navigate to workshop room
	loadhud()
	if !instance_exists(o_narrator) { instance_create(0, 0, o_narrator) }

	global.workshopER_loading = false
	room_goto(r_customlevelworkshop)
}

/// Called when a level fails to load — skip and try another
function workshopER_skip_level() {
	var failed_id = global.workshopER_current_file_id

	// Remove from subscribed pool
	for (var i = 0; i < global.workshopER_pool_count; i++) {
		if global.workshopER_pool[i].file_id == failed_id {
			array_delete(global.workshopER_pool, i, 1)
			global.workshopER_pool_count--
			break
		}
	}

	// Remove from catalog
	for (var i = 0; i < array_length(global.workshopER_catalog_ids); i++) {
		if global.workshopER_catalog_ids[i] == failed_id {
			array_delete(global.workshopER_catalog_ids, i, 1)
			break
		}
	}

	// Try again
	if global.workshopER_pool_count > 0 || array_length(global.workshopER_catalog_ids) > 0 {
		workshopERrandomlevel()
	} else {
		workshopER_game_over()
	}
}

/// Handles end-of-run (no lives left or no levels available)
function workshopER_game_over() {
	audio_stop_all()

	if global.cheats = 0 {
		if global.workshopERhighscore < global.endlesslevel {
			global.workshopERhighscore = global.endlesslevel
			steam_upload_score("Workshop Endless Run", global.workshopERhighscore)
		}
		steam_upload_score("Seasonal Endless Run", global.endlesslevel)
		scr_saveendless()
	}

	global.creditscurrency += floor((global.endlesslevel / 2) * global.creditsmultiplier)
	scr_savestats()

	workshopER_cleanup()

	hidehud()
	instance_destroy(o_levelcounter)
	if room != r_hardmodedeathroom {
		room_goto(r_hardmodedeathroom)
	}
}

/// Unsubscribes auto-subscribed levels and resets all workshopER state
function workshopER_cleanup() {
	// Unsubscribe from auto-subscribed levels
	for (var i = 0; i < array_length(global.workshopER_auto_subscribed); i++) {
		steam_ugc_unsubscribe_item(global.workshopER_auto_subscribed[i])
	}
	global.workshopER_auto_subscribed = []
	global.workshopER_pool = []
	global.workshopER_pool_count = 0
	global.workshopER_catalog_ids = []
	global.workshopER_catalog_scan_done = false
	global.workshopER_loading = false
	global.workshopER_query_id = -1
	global.workshop = 0

	// Destroy persistent async handler
	if instance_exists(o_workshopERloading) {
		instance_destroy(o_workshopERloading)
	}
}

/// Processes async Steam UGC query results for catalog scanning
/// Call this from an Other_69 (Steam Async) event handler
function workshopER_handle_async_catalog(_async_load) {
	if !ds_map_exists(_async_load, "id") { return false }
	if _async_load[? "id"] != global.workshopER_query_id { return false }

	var _result_count = _async_load[? "num_results"]
	var _total = _async_load[? "total_results"]

	// Build a set of subscribed file_ids for quick lookup
	var _sub_set = ds_map_create()
	for (var i = 0; i < global.workshopER_pool_count; i++) {
		_sub_set[? global.workshopER_pool[i].file_id] = true
	}

	// Process each result
	for (var i = 0; i < _result_count; i++) {
		var _key = "published_file_id_" + string(i)
		if ds_map_exists(_async_load, _key) {
			var _fid = _async_load[? _key]
			// Only add if not already subscribed
			if !ds_map_exists(_sub_set, _fid) {
				array_push(global.workshopER_catalog_ids, _fid)
			}
		}
	}

	ds_map_destroy(_sub_set)

	// Check if more pages
	var _items_per_page = 50 // Steam returns up to 50 per page
	if global.workshopER_query_page * _items_per_page < _total {
		global.workshopER_query_page++
		workshopER_query_catalog()
	} else {
		global.workshopER_catalog_scan_done = true
	}

	return true
}
