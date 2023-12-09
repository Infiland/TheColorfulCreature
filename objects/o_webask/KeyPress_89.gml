if os_is_network_connected() {
url_open(url)
} else {
	show_message(loc(646))
}

instance_destroy()