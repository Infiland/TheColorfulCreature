if os_is_network_connected() {
window_set_cursor(cr_default)
url_open("https://store.steampowered.com/app/1651680/The_Colorful_Creature/");
} else {
show_message(loc(646))
}