if os_is_network_connected() {
window_set_cursor(cr_default)
var popup = instance_create(x,y,o_webask)
with popup {
url = "https://forms.gle/8z3NW4D7Sv8pU2q8A"	
}
} else {
show_message(loc(646))
}