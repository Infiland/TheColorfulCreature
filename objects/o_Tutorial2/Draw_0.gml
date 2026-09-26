draw_self()
if !platform_mobile() {
draw_set_font(global.deathfont)
draw_set_halign(fa_center)

controls_key_display(global.controlsjump)
text = "Jump [" + string(keyd) + "]"
if tcc_gamepad_is_connected(0) {
text = "Jump [s_xboxcontrollerscheme,5]"
}
draw_text_scribble(x+90,y+220,text)
}
draw_set_halign(fa_left)
