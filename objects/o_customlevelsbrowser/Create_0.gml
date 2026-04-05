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
browse_query_id = -1
browse_search_text = ""
editing_search = false
browse_page = 1
browse_total = 0

// Async tracking: maps request_id -> level index
async_details = ds_map_create()
async_names = ds_map_create()

// Download state poll timer
download_poll_timer = 0

// Hover tracking
hover_index = -1

// Lazy thumbnail loading queue
thumb_queue = []
thumb_loading = false

// Browse query method (bound to this instance)
send_browse_query = function() {
	browse_state = "loading"
	var qh = steam_ugc_create_query_all(ugc_query_RankedByVote, ugc_match_Items, browse_page)
	if browse_search_text != "" {
		steam_ugc_query_set_search_text(qh, browse_search_text)
	}
	browse_query_id = steam_ugc_send_query(qh)
}

// Populate subscribed levels (NO thumbnail loading here - done lazily in draw)
if global.steam_api = true {
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

		// Load diamond medal time from level metadata
		if file_exists(path_norm + "OtherLevelEditor.sav") {
			ini_open(path_norm + "OtherLevelEditor.sav")
			lvl.medal_required = ini_read_real("Other LE", "Diamond Medal Time", 999999)
			ini_close()
		}

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
		steam_ugc_get_item_update_info(file_id, info)
		if info[? "is_installed"] = 1 { lvl.download_state = "installed" }
		else if info[? "is_downloading"] = 1 { lvl.download_state = "downloading" }
		else if info[? "is_download_pending"] = 1 { lvl.download_state = "pending" }
		else { lvl.download_state = "not_installed" }
		ds_map_destroy(info)

		// Request Steam details (async) - owner name will be requested in Other_69 callback
		var req_id = steam_ugc_request_item_details(file_id, 30)
		async_details[? req_id] = j

		levels[j] = lvl
		j++
	}

	levels_count = j
	ds_list_destroy(steam_list)

	// Calculate scroll max
	var total_rows = ceil(real(levels_count) / grid_cols)
	var visible_rows = floor((grid_bottom_y - grid_top_y) / (tile_h + grid_gap))
	if total_rows > visible_rows {
		scroll_max = (total_rows - visible_rows) * (tile_h + grid_gap)
	}
}
