if os_is_network_connected() {
url_open(url)
if steam_get_achievement("WORLD_WIDE_WEB") { steam_set_achievement("WORLD_WIDE_WEB") }
} else {
	show_message(loc(646))
}

instance_destroy()