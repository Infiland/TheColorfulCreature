function scr_multiplayercontrolsplayer(){

switch(global.multiplayerplayercontrols[multiplayerplayer-1]) {
case(0):
key_restart = timing_keyboard_down(vk_rcontrol)
key_left = timing_keyboard_down(vk_left)
key_right = timing_keyboard_down(vk_right)
key_jump = timing_keyboard_down(vk_up)
key_interact = timing_keyboard_pressed(vk_down)
break;
case(1):
key_restart = timing_keyboard_down(ord("R"))
key_left = timing_keyboard_down(ord("A"))
key_right = timing_keyboard_down(ord("D"))
key_jump = timing_keyboard_down(ord("W"))
key_interact = timing_keyboard_pressed(ord("S"))
break;
case(2):
key_restart = timing_keyboard_down(ord("P"))
key_left = timing_keyboard_down(ord("J"))
key_right = timing_keyboard_down(ord("L"))
key_jump = timing_keyboard_down(ord("I"))
key_interact = timing_keyboard_pressed(ord("K"))
break;
case(3):
key_restart = timing_keyboard_down(vk_numpad9)
key_left = timing_keyboard_down(vk_numpad4)
key_right = timing_keyboard_down(vk_numpad6)
key_jump = timing_keyboard_down(vk_numpad8)
key_interact = timing_keyboard_pressed(vk_numpad5)
break;
case(4):
var _pad = multiplayerplayer - 1
key_restart = (tcc_gamepad_button_check(_pad,global.gp_bind_restart))
key_left = (tcc_gamepad_axis_value(_pad,gp_axislh) < -0.2 || tcc_gamepad_button_check(_pad,global.gp_bind_moveleft))
key_right = (tcc_gamepad_axis_value(_pad,gp_axislh) > 0.2 || tcc_gamepad_button_check(_pad,global.gp_bind_moveright))
key_jump = tcc_gamepad_button_check(_pad,global.gp_bind_jump)
key_interact = (tcc_gamepad_button_check_pressed(_pad,global.gp_bind_interact))
if key_left || key_right { window_set_cursor(cr_none) } //Cursor appears during gameplay
break;
}
}