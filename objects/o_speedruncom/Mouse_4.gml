if os_is_network_connected() {
window_set_cursor(cr_default)
var popup = instance_create(x,y,o_webask)
with popup {
url = "https://www.speedrun.com/tcc/"	
}
} else {
show_message(loc(646))
}