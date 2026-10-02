if (!timing_instance_step()) exit;
key_left = timing_keyboard_down(vk_left) || (tcc_gamepad_button_check(4,gp_padl)) || timing_keyboard_down(ord("A"));
key_right = timing_keyboard_down(vk_right) || (tcc_gamepad_button_check(4,gp_padr)) || timing_keyboard_down(ord("D"));
if global.soundchange = 2 {
if key_left {
if global.soundvolume < 1.02 {
if global.soundvolume > -0.01 {	
global.soundvolume -= 0.01
}}}
if key_right {
if global.soundvolume < 1.01 {	
global.soundvolume += 0.01
}
}
}
if timing_keyboard_released(vk_left) or tcc_gamepad_button_check_released(0,gp_padl) or timing_keyboard_released(ord("A")) or timing_keyboard_released(vk_right) or tcc_gamepad_button_check_released(0,gp_padr) or timing_keyboard_released(ord("D")) { scr_savesettings() }

if global.soundchange = 0 { image_index = 0 }
if global.soundchange = 1 { image_index = 0 }
if global.soundchange = 2 { image_index = 1 }

if global.choosesettings != 2 { x = lerp(x,camera_get_view_x(view_camera[0])-256,0.2 * (60 / global.maxfps)) }
if global.choosesettings = 2 { x = lerp(x,camera_get_view_x(view_camera[0])+32,0.2 * (60 / global.maxfps)) }