if os_is_network_connected() {
if !steam_get_achievement("WORLD_WIDE_WEB") { steam_set_achievement("WORLD_WIDE_WEB") }
url_open(url)
} else {
	show_message(loc(646))
}

instance_destroy()