draw_self()
if os_type != os_android {
draw_set_font(global.deathfont)
draw_set_halign(fa_center)

controls_key_display(global.controlsjump)
text = "Jump [" + string(keyd) + "]"
if gamepad_is_connected(0) {
text = "Jump [s_xboxcontrollerscheme,5]"	
}
draw_text_scribble(x+90,y+220,text)
}
draw_set_halign(fa_left)