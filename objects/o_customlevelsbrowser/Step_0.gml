/// @description Handle scrolling, clicks, search, tab switching

// Overlay fade in
overlay_alpha = lerp(overlay_alpha, 1, 0.15 * (60 / global.maxfps))

// Smooth scrolling
scroll = lerp(scroll, scroll_target, 0.2 * (60 / global.maxfps))
scroll = clamp(scroll, 0, max(0, scroll_max))

// Mouse wheel scrolling
if mouse_wheel_down() { scroll_target += 60 }
if mouse_wheel_up() { scroll_target -= 60 }
scroll_target = clamp(scroll_target, 0, max(0, scroll_max))

// Gamepad back
if gamepad_button_check_pressed(0, gp_face2) {
	event_perform(ev_keypress, vk_escape)
}

// Recalculate scroll_max based on active tab
var _active_count = (tab = 0) ? levels_count : browse_count
var _actual_grid_top = (tab = 1) ? 148 : grid_top_y
var total_rows = ceil(real(_active_count) / grid_cols)
var visible_rows = floor((grid_bottom_y - _actual_grid_top) / (tile_h + grid_gap))
if total_rows > visible_rows {
	scroll_max = (total_rows - visible_rows) * (tile_h + grid_gap)
} else {
	scroll_max = 0
}
scroll_target = clamp(scroll_target, 0, max(0, scroll_max))

// GUI mouse position
var _mx = device_mouse_x_to_gui(0)
var _my = device_mouse_y_to_gui(0)

// Click handling
if mouse_check_button_pressed(mb_left) {
	var _panel_x = grid_margin_x - 20
	var _panel_w = 1024 - 2 * _panel_x

	// Close button (X)
	var _xbtn_x = _panel_x + _panel_w - 18
	var _xbtn_y = 48
	if (_mx >= _xbtn_x - 14 && _mx <= _xbtn_x + 14 && _my >= _xbtn_y - 4 && _my <= _xbtn_y + 24) {
		instance_destroy()
		exit
	}

	// Tab buttons
	var _tab_y = 80
	var _tab_h = 28
	var _tab1_x = 512 - 160
	var _tab2_x = 512 + 10
	var _tab_w = 150

	if (_mx >= _tab1_x && _mx <= _tab1_x + _tab_w && _my >= _tab_y && _my <= _tab_y + _tab_h) {
		if tab != 0 {
			tab = 0
			scroll = 0
			scroll_target = 0
			editing_search = false
		}
	}
	if (_mx >= _tab2_x && _mx <= _tab2_x + _tab_w && _my >= _tab_y && _my <= _tab_y + _tab_h) {
		if tab != 1 {
			tab = 1
			scroll = 0
			scroll_target = 0
			// Auto-load popular levels on first switch to browse tab
			if browse_state = "idle" {
				browse_page = 1
				send_browse_query()
			}
		}
	}

	// Search field click (browse tab)
	if tab = 1 {
		var _search_x = grid_margin_x
		var _search_y = 116
		var _search_w = 1024 - 2 * grid_margin_x
		var _search_h = 24

		if (_mx >= _search_x && _mx <= _search_x + _search_w && _my >= _search_y && _my <= _search_y + _search_h) {
			editing_search = true
			keyboard_string = browse_search_text
		} else if editing_search {
			editing_search = false
		}
	}

	// Grid tile click
	if hover_index >= 0 {
		var _active_levels = (tab = 0) ? levels : browse_levels
		var _lvl = _active_levels[hover_index]

		if _lvl.banned { /* do nothing */ }
		else if tab = 0 {
			// Subscribed tab: play the level with download safety check
			var info = ds_map_create()
			steam_ugc_get_item_update_info(_lvl.file_id, info)
			var _is_installed = info[? "is_installed"]
			var _is_downloading = info[? "is_downloading"]
			var _is_pending = info[? "is_download_pending"]
			ds_map_destroy(info)

			if _is_installed != 1 || _is_downloading = 1 || _is_pending = 1 {
				// Level still downloading - update state and don't play
				if _is_downloading = 1 { _lvl.download_state = "downloading" }
				else if _is_pending = 1 { _lvl.download_state = "pending" }
				// Could show popup here
			} else if file_exists(_lvl.path + "LevelEditor.sav") {
				// Safe to play
				global.deaths = 0
				global.time = 0
				global.Publish_ID = _lvl.file_id
				global.levelname = _lvl.title
				global.workshopfolder = _lvl.path

				var directory = directory_set(_lvl.path, 1)
				directory = string_replace_all(directory, "\\", "/")

				if file_exists(directory + "OtherLevelEditor.sav") {
					ini_open(directory + "OtherLevelEditor.sav")
					global.LELevelWidthBlocks = ini_read_real("Other LE", "Level Width Blocks", 32)
					global.LELevelHeightBlocks = ini_read_real("Other LE", "Level Height Blocks", 22)
					ini_close()
				}

				room_set_width(r_customlevelworkshop, global.LELevelWidthBlocks * 32)
				room_set_height(r_customlevelworkshop, 64 + (global.LELevelHeightBlocks * 32))

				// Clean up browser before transitioning
				instance_create(x, y, o_customlevelworkshopcreate)
				loadhud()

				var medal_dir = directory_set("/Custom/Workshop/Medals/" + string(_lvl.file_id) + "/")
				if !directory_exists(medal_dir) { directory_create(medal_dir) }

				if !instance_exists(o_narrator) { instance_create(x, y, o_narrator) }
				instance_destroy(o_coincounter)
				instance_destroy()
				exit
			}
		} else {
			// Browse tab: subscribe + download
			if _lvl.download_state = "not_installed" || _lvl.download_state = "unknown" {
				steam_ugc_subscribe_item(_lvl.file_id)
				_lvl.download_state = "pending"
			}
		}
	}

	// Load More button (browse tab)
	if tab = 1 && browse_state = "loaded" && browse_count < browse_total {
		var _lm_row = ceil(real(browse_count) / grid_cols)
		var _lm_y = _actual_grid_top + _lm_row * (tile_h + grid_gap) - scroll
		if (_mx >= grid_margin_x && _mx <= 1024 - grid_margin_x && _my >= _lm_y && _my < _lm_y + 40) {
			browse_page++
			send_browse_query()
		}
	}
}

// Search field keyboard input (browse tab)
if tab = 1 && editing_search {
	browse_search_text = keyboard_string

	if keyboard_check_pressed(vk_enter) {
		editing_search = false
		browse_page = 1
		browse_levels = []
		browse_count = 0
		scroll = 0
		scroll_target = 0
		send_browse_query()
	}

	if keyboard_check_pressed(vk_escape) {
		editing_search = false
		// Don't close the browser, just stop editing
		exit
	}
}

// Download state polling (every 60 frames)
download_poll_timer++
if download_poll_timer >= 60 {
	download_poll_timer = 0

	// Update download states for subscribed levels
	for (var i = 0; i < levels_count; i++) {
		var _lvl = levels[i]
		if _lvl.download_state = "downloading" || _lvl.download_state = "pending" {
			var info = ds_map_create()
			steam_ugc_get_item_update_info(_lvl.file_id, info)
			if info[? "is_installed"] = 1 {
				_lvl.download_state = "installed"
				// Reset thumb_checked so lazy loader picks it up
				_lvl.thumb_checked = false
			} else if info[? "is_downloading"] = 1 {
				_lvl.download_state = "downloading"
			}
			ds_map_destroy(info)
		}
	}

	// Update download states for browse results
	for (var i = 0; i < browse_count; i++) {
		var _lvl = browse_levels[i]
		if _lvl.download_state = "downloading" || _lvl.download_state = "pending" {
			var info = ds_map_create()
			steam_ugc_get_item_update_info(_lvl.file_id, info)
			if info[? "is_installed"] = 1 { _lvl.download_state = "installed" }
			else if info[? "is_downloading"] = 1 { _lvl.download_state = "downloading" }
			ds_map_destroy(info)
		}
	}
}

