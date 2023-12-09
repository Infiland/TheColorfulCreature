function scr_multiplayercontrolsplayer(){
switch(multiplayerplayer) {
//Player 1
case(1):
switch(global.multiplayerplayercontrols[0]) {
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
}
break;
//Player 2
case(2):
switch(global.multiplayerplayercontrols[1]) {
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
}
break;
//Player 3
case(3):
switch(global.multiplayerplayercontrols[2]) {
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
}
break;
//Player 4
case(4):
switch(global.multiplayerplayercontrols[3]) {
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
}
break;
}
}