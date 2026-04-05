/// @description Poll download state and handle timeout

// Only poll when actively waiting for a download
if state != "waiting" { exit }

wait_frames++

// Animated dots
dot_timer++
if dot_timer >= 20 {
	dots = (dots + 1) mod 4
	dot_timer = 0
}

// Timeout check
if wait_frames >= max_wait {
	state = "idle"
	global.workshopER_loading = false
	workshopER_skip_level()
	exit
}

// Poll every 30 frames
poll_timer++
if poll_timer < 30 { exit }
poll_timer = 0

var info = ds_map_create()
steam_ugc_get_item_update_info(target_file_id, info)
var is_installed = info[? "is_installed"]
ds_map_destroy(info)

if is_installed = 1 {
	// Check if file is actually available
	var file_info = ds_map_create()
	steam_ugc_get_item_install_info(target_file_id, file_info)
	var folder = file_info[? "folder"]
	ds_map_destroy(file_info)

	folder = string_replace_all(string(folder), "\\", "/")
	if (string_copy(folder, string_length(folder), 1) != "/") { folder += "/" }

	if file_exists(folder + "LevelEditor.sav") {
		state = "idle"
		global.workshopER_loading = false
		workshopER_goto_level(target_file_id)
	}
}
