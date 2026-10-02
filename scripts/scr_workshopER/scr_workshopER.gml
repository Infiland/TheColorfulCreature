/// @description Workshop Endless Run (Mode 4) core functions

/// Builds the level pool from subscribed workshop items
/// Returns true if pool has at least 1 level
function workshopER_build_pool() {
	global.workshopER_pool = []
	global.workshopER_pool_count = 0
	global.workshopER_auto_subscribed = []

	if !global.steam_api { return false }

	var steam_list = ds_list_create()
	tcc_steam_ugc_get_subscribed_items(steam_list)

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
	global.workshopER_query_id = -1
	if !global.steam_api {
		global.workshopER_catalog_scan_done = true
		return
	}
	var qh = tcc_steam_ugc_create_query_all(ugc_query_RankedByPublicationDate, ugc_match_Items, global.workshopER_query_page)
	if qh == 0 || qh == -1 {
		global.workshopER_catalog_scan_done = true
		return
	}
	global.workshopER_query_id = tcc_steam_ugc_send_query(qh)
	if global.workshopER_query_id <= 0 {
		global.workshopER_query_id = -1
		global.workshopER_catalog_scan_done = true
	}
}

/// Core level selection for Workshop Endless Run
function workshopERrandomlevel() {
	tcc_randomize()

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
	tcc_steam_ugc_get_item_install_info(file_id, info)
	var folder = ""
	if ds_map_exists(info, "folder") { folder = info[? "folder"] }
	ds_map_destroy(info)

	folder = string_replace_all(string(folder), "\\", "/")
	if (string_copy(folder, string_length(folder), 1) != "/") { folder += "/" }

	if folder != "/" && level_exists(folder) {
		// Already available locally
		global.workshopER_current_file_id = file_id
		global.workshopER_last_file_id = file_id
		workshopER_goto_level(file_id)
		return
	}

	// Need to subscribe and download
	tcc_steam_ugc_subscribe_item(file_id)
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
	tcc_steam_ugc_get_item_install_info(_file_id, _info)
	var _folder = ""
	if ds_map_exists(_info, "folder") { _folder = _info[? "folder"] }
	ds_map_destroy(_info)

	_folder = string_replace_all(string(_folder), "\\", "/")
	if (_folder == "") {
		workshopER_skip_level()
		return
	}
	if (string_copy(_folder, string_length(_folder), 1) != "/") _folder += "/"

	if !level_exists(_folder) {
		workshopER_skip_level()
		return
	}

	global.workshopfolder = _folder
	global.Publish_ID = _file_id

	if (!level_prepare_room(_folder, r_customlevelworkshop, true)) {
        workshopER_skip_level();
        return;
    }

	// Play music from workshop level metadata
	scr_leveleditormusic(_folder)

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
			platform_submit_score("Workshop Endless Run", global.workshopERhighscore)
		}
		platform_submit_score("Seasonal Endless Run", global.endlesslevel)
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
		tcc_steam_ugc_unsubscribe_item(global.workshopER_auto_subscribed[i])
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

/// Decode the extension's list-of-maps schema without retaining async-owned DS
/// handles. Steam releases the query itself before delivering this callback.
function workshopER_catalog_callback(_event, _request) {
	var _response = {matched:false, ok:false, count:0, total:0, ids:[]}
	if !level_finite(_request) || _request <= 0 { return _response }
	if !(is_real(_event) || is_handle(_event)) || !ds_exists(_event, ds_type_map) { return _response }
	if !ds_map_exists(_event, "event_type") || !ds_map_exists(_event, "id") { return _response }
	if _event[? "event_type"] != "ugc_query" || _event[? "id"] != _request { return _response }
	_response.matched = true
	if !ds_map_exists(_event, "result") || _event[? "result"] != ugc_result_success { return _response }
	if !ds_map_exists(_event, "num_results") || !ds_map_exists(_event, "total_matching") { return _response }
	var _count = _event[? "num_results"]
	var _total = _event[? "total_matching"]
	if !level_finite(_count) || _count < 0 || _count > 50 || floor(_count) != _count { return _response }
	if !level_finite(_total) || _total < _count || floor(_total) != _total { return _response }
	if _count > 0 {
		if !ds_map_exists(_event, "results_list") { return _response }
		var _results = _event[? "results_list"]
		if !(is_real(_results) || is_handle(_results)) || !ds_exists(_results, ds_type_list) { return _response }
		for (var _i = 0; _i < min(_count, ds_list_size(_results)); ++_i) {
			var _item = _results[| _i]
			if !(is_real(_item) || is_handle(_item)) || !ds_exists(_item, ds_type_map) { continue }
			if !ds_map_exists(_item, "result") || _item[? "result"] != ugc_result_success { continue }
			if !ds_map_exists(_item, "published_file_id") { continue }
			var _fid = _item[? "published_file_id"]
			if !is_numeric(_fid) || _fid <= 0 { continue }
			if !is_int64(_fid) && (!level_finite(_fid) || floor(_fid) != _fid) { continue }
			array_push(_response.ids, _fid)
		}
	}
	_response.count = _count
	_response.total = _total
	_response.ok = true
	return _response
}

/// Processes only the active Workshop Endless catalog request. A completed or
/// failed request is consumed once; failed scans fall back to installed levels.
function workshopER_handle_async_catalog(_async_load) {
	if !variable_global_exists("endless") || global.endless != 1 { return false }
	if !variable_global_exists("endlessrunmode") || global.endlessrunmode != 4 { return false }
	if global.workshopER_catalog_scan_done { return false }
	var _response = workshopER_catalog_callback(_async_load, global.workshopER_query_id)
	if !_response.matched { return false }
	global.workshopER_query_id = -1
	if !_response.ok {
		global.workshopER_catalog_scan_done = true
		return false
	}

	// String keys preserve adjacent Int64 file IDs above double precision, while
	// excluding both subscribed items and IDs repeated across catalog pages.
	var _seen = ds_map_create()
	for (var _i = 0; _i < global.workshopER_pool_count; ++_i) {
		_seen[? string(global.workshopER_pool[_i].file_id)] = true
	}
	for (var _i = 0; _i < array_length(global.workshopER_catalog_ids); ++_i) {
		_seen[? string(global.workshopER_catalog_ids[_i])] = true
	}
	for (var _i = 0; _i < array_length(_response.ids); ++_i) {
		var _fid = _response.ids[_i]
		var _key = string(_fid)
		if !ds_map_exists(_seen, _key) {
			array_push(global.workshopER_catalog_ids, _fid)
			_seen[? _key] = true
		}
	}
	ds_map_destroy(_seen)

	// An empty page is terminal even if Steam's total changed during the scan.
	if _response.count > 0 && global.workshopER_query_page * 50 < _response.total {
		global.workshopER_query_page++
		workshopER_query_catalog()
	} else {
		global.workshopER_catalog_scan_done = true
	}
	return true
}

/// Synthetic extension callbacks exercise production parsing/consumption. This
/// check neither calls Steam nor navigates; every touched global is restored.
function workshopER_catalog_selfcheck() {
	var _assert = function(_ok, _why) { if !_ok { throw "Workshop catalog self-check failed: " + _why } }
	var _names = ["endless", "endlessrunmode", "steam_api", "workshopER_query_id", "workshopER_query_page",
		"workshopER_catalog_scan_done", "workshopER_catalog_ids", "workshopER_pool", "workshopER_pool_count"]
	var _saved = []
	for (var _i = 0; _i < array_length(_names); ++_i) {
		_saved[_i] = variable_global_exists(_names[_i]) ? variable_global_get(_names[_i]) : undefined
	}
	global.endless = 1
	global.endlessrunmode = 4
	global.steam_api = false
	global.workshopER_query_id = 9
	global.workshopER_query_page = 1
	global.workshopER_catalog_scan_done = false
	global.workshopER_catalog_ids = [int64(200)]
	global.workshopER_pool = [{file_id:int64(100)}]
	global.workshopER_pool_count = 1
	var _a = int64("9007199254740993")
	var _b = int64("9007199254740994")
	var _ids = [int64(100), int64(200), _a, _a, _b, int64(0), int64(300)]
	var _event = ds_map_create()
	var _results = ds_list_create()
	ds_map_add_list(_event, "results_list", _results)
	for (var _i = 0; _i < array_length(_ids); ++_i) {
		var _item = ds_map_create()
		_item[? "published_file_id"] = _ids[_i]
		_item[? "result"] = (_i == 6) ? 0 : ugc_result_success
		ds_list_add(_results, _item)
		ds_list_mark_as_map(_results, _i)
	}
	_event[? "id"] = 9
	_event[? "event_type"] = "ugc_query"
	_event[? "result"] = ugc_result_success
	_event[? "num_results"] = array_length(_ids)
	_event[? "total_matching"] = 125
	var _response = workshopER_catalog_callback(_event, 9)
	_assert(_response.ok && _response.total == 125 && array_length(_response.ids) == 5, "actual nested schema and total_matching; failed/invalid items excluded")
	_assert(!workshopER_catalog_callback(_event, -1).matched, "no active request")
	_assert(!workshopER_catalog_callback(undefined, 9).matched, "malformed event ignored")
	_event[? "total_matching"] = array_length(_ids)
	_event[? "event_type"] = "ugc_download_item"
	_assert(!workshopER_handle_async_catalog(_event) && global.workshopER_query_id == 9, "wrong event cannot consume query")
	_event[? "event_type"] = "ugc_query"
	_event[? "id"] = 8
	_assert(!workshopER_handle_async_catalog(_event) && global.workshopER_query_id == 9, "stale request ignored")
	_event[? "id"] = 9
	_assert(workshopER_handle_async_catalog(_event), "matching query consumed")
	_assert(array_length(global.workshopER_catalog_ids) == 3, "subscribed and repeated catalog IDs excluded")
	_assert(is_int64(global.workshopER_catalog_ids[1]) && string(global.workshopER_catalog_ids[1]) == string(_a)
		&& string(global.workshopER_catalog_ids[2]) == string(_b), "adjacent large Int64 IDs remain distinct")
	_assert(global.workshopER_query_id == -1 && global.workshopER_catalog_scan_done, "last page closes request")
	_assert(!workshopER_handle_async_catalog(_event) && array_length(global.workshopER_catalog_ids) == 3, "duplicate completion ignored")
	global.workshopER_query_id = 10
	global.workshopER_catalog_scan_done = false
	_event[? "id"] = 10
	_event[? "result"] = 0
	_assert(!workshopER_handle_async_catalog(_event) && array_length(global.workshopER_catalog_ids) == 3
		&& global.workshopER_query_id == -1 && global.workshopER_catalog_scan_done, "failed request cannot mutate catalog or continue scan")
	ds_map_destroy(_event)
	_event = ds_map_create()
	_event[? "id"] = 11
	_event[? "event_type"] = "ugc_query"
	_event[? "result"] = ugc_result_success
	_event[? "num_results"] = 1
	_event[? "total_matching"] = 1
	_assert(workshopER_catalog_callback(_event, 11).matched && !workshopER_catalog_callback(_event, 11).ok, "nonempty response requires results_list")
	_event[? "num_results"] = 0
	_event[? "total_matching"] = 0
	global.workshopER_query_id = 11
	global.workshopER_catalog_scan_done = false
	global.endless = 0
	_assert(!workshopER_handle_async_catalog(_event) && global.workshopER_query_id == 11, "callback after leaving Endless ignored")
	global.endless = 1
	_assert(workshopER_handle_async_catalog(_event) && global.workshopER_catalog_scan_done, "successful empty page needs no results_list")
	ds_map_destroy(_event)
	global.workshopER_catalog_scan_done = false
	workshopER_query_catalog()
	_assert(global.workshopER_query_id == -1 && global.workshopER_catalog_scan_done, "unavailable Steam stops scan without sending")
	for (var _i = 0; _i < array_length(_names); ++_i) variable_global_set(_names[_i], _saved[_i])
	return true
}
