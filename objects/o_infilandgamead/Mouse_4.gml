if instance_exists(o_progressask) { exit }

if os_is_network_connected() {
window_set_cursor(cr_default)
var lnk = link
var popup = instance_create(x,y,o_webask)
with popup {
url = lnk
}
} else {
show_message(loc("YOU_ARE_DISCONNECTED_PLEASE_TURN_ON_YOUR_INTERNET_CONNECTION"))
}