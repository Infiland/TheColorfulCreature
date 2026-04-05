if instance_exists(o_progressask) { exit }

if os_is_network_connected() {
	window_set_cursor(cr_default)
	if !instance_exists(o_newsviewer) {
		instance_create_depth(0, 0, -9999, o_newsviewer)
	}
} else {
	show_message(loc("YOU_ARE_DISCONNECTED_PLEASE_TURN_ON_YOUR_INTERNET_CONNECTION"))
}