function scr_multiplayercontrolsplayer(){

switch(global.multiplayerplayercontrols[multiplayerplayer-1]) {
case(0):
key_restart = keyboard_check(vk_rcontrol)
key_left = keyboard_check(vk_left)
key_right = keyboard_check(vk_right)
key_jump = keyboard_check(vk_up)
key_interact = keyboard_check_pressed(vk_down)
break;
case(1):
key_restart = keyboard_check(ord("R"))
key_left = keyboard_check(ord("A"))
key_right = keyboard_check(ord("D"))
key_jump = keyboard_check(ord("W"))
key_interact = keyboard_check_pressed(ord("S"))
break;
case(2):
key_restart = keyboard_check(ord("P"))
key_left = keyboard_check(ord("J"))
key_right = keyboard_check(ord("L"))
key_jump = keyboard_check(ord("I"))
key_interact = keyboard_check_pressed(ord("K"))
break;
case(3):
key_restart = keyboard_check(vk_numpad9)
key_left = keyboard_check(vk_numpad4)
key_right = keyboard_check(vk_numpad6)
key_jump = keyboard_check(vk_numpad8)
key_interact = keyboard_check_pressed(vk_numpad5)
break;
case(4):
key_restart = (gamepad_button_check(0,gp_shoulderlb))
key_left = (gamepad_axis_value(0,gp_axislh) < -0.2 || gamepad_button_check(0,gp_padl))
key_right = (gamepad_axis_value(0,gp_axislh) > 0.2 || gamepad_button_check(0,gp_padr))
key_jump = gamepad_button_check(0,gp_face1)
key_interact = (gamepad_button_check_pressed(0,gp_shoulderrb))
if key_left || key_right { window_set_cursor(cr_none) } //Cursor appears during gameplay
break;
}
}