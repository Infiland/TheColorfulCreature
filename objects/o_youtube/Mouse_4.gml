if instance_exists(o_progressask) { exit }
if instance_exists(o_quitask) { exit }

if os_is_network_connected() {
window_set_cursor(cr_default)
var popup = instance_create(x,y,o_webask)
with popup {
url = "https://www.youtube.com/channel/UC3d8UnmOezFZeCwY8K01PSw"	
}
} else {
show_message(loc("YOU_ARE_DISCONNECTED_PLEASE_TURN_ON_YOUR_INTERNET_CONNECTION"))
}