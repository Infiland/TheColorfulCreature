if (!variable_global_exists("timing_confirmation_dispatch_active") || !global.timing_confirmation_dispatch_active) exit;
if os_is_network_connected() {
if !achievement_earned("WORLD_WIDE_WEB") { achievement_award("WORLD_WIDE_WEB") }
url_open(url)
} else {
	show_message(loc("YOU_ARE_DISCONNECTED_PLEASE_TURN_ON_YOUR_INTERNET_CONNECTION"))
}

instance_destroy()
