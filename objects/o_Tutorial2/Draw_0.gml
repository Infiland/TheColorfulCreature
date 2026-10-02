draw_self()
if !platform_mobile() {
draw_set_font(global.deathfont)
draw_set_halign(fa_center)

controls_key_display(global.controlsjump)
text = "Jump [" + string(keyd) + "]"
if gamepad_ui_connected() {
text = "Jump [" + gamepad_button_display_name(gamepad_remap_get(2)) + "]"
}
draw_text_scribble(x+90,y+220,text)
}
draw_set_halign(fa_left)
