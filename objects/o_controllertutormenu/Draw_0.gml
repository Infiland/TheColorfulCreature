if gamepad_is_connected(0) {
draw_set_font(global.deathfont)
draw_controller_scheme(0,0,57,"Move")
draw_controller_scheme(0,64,5,"Accept")
draw_controller_scheme(0,128,7,"Back")
}