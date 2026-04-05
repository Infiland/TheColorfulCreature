/// @description Async - Steam event handler

var _event_type = async_load[? "event_type"]
var _map_id = async_load[? "id"]
var _result = async_load[? "result"]

// Browse query results
if _event_type = "ugc_query" && _map_id = browse_query_id {
	if _result = ugc_result_success {
		var _num = async_load[? "num_results"]
		browse_total = async_load[? "total_matching"]

		if browse_page = 1 {
			browse_levels = []
			browse_count = 0
		}

		var _results = async_load[? "results_list"]
		if !is_undefined(_results) {
			for (var i = 0; i < ds_list_size(_results); i++) {
				var _item = _results[| i]

				var lvl = {}
				lvl.file_id = _item[? "published_file_id"]
				lvl.path = ""
				lvl.title = _item[? "title"]
				lvl.owner_name = "Unknown"
				lvl.owner_id = _item[? "steam_id_owner"]
				lvl.likes = _item[? "votes_up"]
				lvl.dislikes = _item[? "votes_down"]
				lvl.tags = ""
				lvl.difficulty = 0
				lvl.banned = (_item[? "banned"] = 1)
				lvl.featured = false
				lvl.loaded = true
				lvl.thumb_spr = -1
				lvl.thumb_checked = true
				lvl.thumb_handle = _item[? "handle_preview_file"] // UGC handle for preview download
				lvl.thumb_downloading = false
				lvl.medal_time = 9999999
				lvl.medal_required = 999999
				lvl.download_state = "unknown"

				// Parse tags for difficulty (handle both array and string formats)
				var _tags = _item[? "tags"]
				if is_array(_tags) {
					for (var t = 0; t < array_length(_tags); t++) {
						var _tag = string(_tags[t])
						if _tag = "Easy" { lvl.difficulty = 1 }
						if _tag = "Medium" { lvl.difficulty = 2 }
						if _tag = "Difficult" { lvl.difficulty = 3 }
						if _tag = "Insane" { lvl.difficulty = 4 }
						if _tag = "Unfair" { lvl.difficulty = 5 }
						if _tag = "Impossible" { lvl.difficulty = 6 }
						if _tag = "Level of the Week" { lvl.featured = true }
					}
				} else if is_string(_tags) {
					if string_count("Easy", _tags) > 0 { lvl.difficulty = 1 }
					if string_count("Medium", _tags) > 0 { lvl.difficulty = 2 }
					if string_count("Difficult", _tags) > 0 { lvl.difficulty = 3 }
					if string_count("Insane", _tags) > 0 { lvl.difficulty = 4 }
					if string_count("Unfair", _tags) > 0 { lvl.difficulty = 5 }
					if string_count("Impossible", _tags) > 0 { lvl.difficulty = 6 }
					if string_count("Level of the Week", _tags) > 0 { lvl.featured = true }
				}

				// Check if already subscribed/installed
				var info = ds_map_create()
				steam_ugc_get_item_update_info(lvl.file_id, info)
				if info[? "is_installed"] = 1 { lvl.download_state = "installed" }
				else if info[? "is_downloading"] = 1 { lvl.download_state = "downloading" }
				else if info[? "is_download_pending"] = 1 { lvl.download_state = "pending" }
				else { lvl.download_state = "not_installed" }
				ds_map_destroy(info)

				// Request persona name (store with "browse:" prefix to disambiguate)
				var _name_req = steam_get_user_persona_name(lvl.owner_id)
				async_names[? _name_req] = "browse:" + string(browse_count)

				browse_levels[browse_count] = lvl
				browse_count++
			}
		}

		browse_state = "loaded"
	} else {
		browse_state = "error"
	}
	exit
}

// Item details response (for subscribed levels)
if ds_map_exists(async_details, _map_id) {
	if _result = ugc_result_success {
		var _idx = async_details[? _map_id]
		if _idx >= 0 && _idx < levels_count {
			var _lvl = levels[_idx]
			_lvl.title = async_load[? "title"]
			_lvl.owner_id = async_load[? "steam_id_owner"]
			_lvl.likes = async_load[? "votes_up"]
			_lvl.dislikes = async_load[? "votes_down"]
			_lvl.banned = (async_load[? "banned"] = 1)
			_lvl.loaded = true

			// Parse tags for difficulty and featured
			var _tags = async_load[? "tags"]
			if is_array(_tags) {
				for (var t = 0; t < array_length(_tags); t++) {
					var _tag = string(_tags[t])
					if _tag = "Easy" { _lvl.difficulty = 1 }
					if _tag = "Medium" { _lvl.difficulty = 2 }
					if _tag = "Difficult" { _lvl.difficulty = 3 }
					if _tag = "Insane" { _lvl.difficulty = 4 }
					if _tag = "Unfair" { _lvl.difficulty = 5 }
					if _tag = "Impossible" { _lvl.difficulty = 6 }
					if _tag = "Level of the Week" { _lvl.featured = true }
				}
			} else if is_string(_tags) {
				if string_count("Easy", _tags) > 0 { _lvl.difficulty = 1 }
				if string_count("Medium", _tags) > 0 { _lvl.difficulty = 2 }
				if string_count("Difficult", _tags) > 0 { _lvl.difficulty = 3 }
				if string_count("Insane", _tags) > 0 { _lvl.difficulty = 4 }
				if string_count("Unfair", _tags) > 0 { _lvl.difficulty = 5 }
				if string_count("Impossible", _tags) > 0 { _lvl.difficulty = 6 }
				if string_count("Level of the Week", _tags) > 0 { _lvl.featured = true }
			}

			// Request persona name for owner (store with "sub:" prefix)
			var _name_req = steam_get_user_persona_name(_lvl.owner_id)
			async_names[? _name_req] = "sub:" + string(_idx)
		}
	}
	ds_map_delete(async_details, _map_id)
	exit
}

// Persona name response
if ds_map_exists(async_names, _map_id) {
	var _name = async_load[? "persona_name"]
	if !is_undefined(_name) && is_string(_name) {
		var _key = async_names[? _map_id]

		if is_string(_key) {
			if string_copy(_key, 1, 4) = "sub:" {
				var _idx = real(string_delete(_key, 1, 4))
				if _idx >= 0 && _idx < levels_count {
					levels[_idx].owner_name = _name
				}
			} else if string_copy(_key, 1, 7) = "browse:" {
				var _idx = real(string_delete(_key, 1, 7))
				if _idx >= 0 && _idx < browse_count {
					browse_levels[_idx].owner_name = _name
				}
			}
		}
	}
	ds_map_delete(async_names, _map_id)
}
