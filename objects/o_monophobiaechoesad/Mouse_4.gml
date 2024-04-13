if instance_exists(o_progressask) { exit }

if os_is_network_connected() {
window_set_cursor(cr_default)
var popup = instance_create(x,y,o_webask)
with popup {
url = "https://infiland.itch.io/monophobia-echoes"	
}
} else {
show_message(loc(646))
}