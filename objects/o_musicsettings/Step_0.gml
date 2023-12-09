key_left = keyboard_check(vk_left) || (gamepad_button_check(4,gp_padl)) || keyboard_check(ord("A"));
key_right = keyboard_check(vk_right) || (gamepad_button_check(4,gp_padr)) || keyboard_check(ord("D"));
if global.soundchange = 1 {
if key_left {
if global.musicvolume < 1.02 {
if global.musicvolume > -0.01 {	
global.musicvolume -= 0.01
}}}
if key_right {
if global.musicvolume < 1.01 {	
global.musicvolume += 0.01
}
}
}
audio_sound_gain(m_mainmenu,global.musicvolume,1)
if keyboard_check_released(vk_left) or gamepad_button_check_released(4,gp_padl) or keyboard_check_released(ord("A")) or keyboard_check_released(vk_right) or gamepad_button_check_released(4,gp_padr) or keyboard_check_released(ord("D")) { scr_savesettings() }

if global.soundchange = 0 { image_index = 0 }
if global.soundchange = 1 { image_index = 1 }
if global.soundchange = 2 { image_index = 0 }

if global.choosesettings != 2 { x = lerp(x,camera_get_view_x(view_camera[0])-256,0.2 * (60 / global.maxfps)) }
if global.choosesettings = 2 { x = lerp(x,camera_get_view_x(view_camera[0])+32,0.2 * (60 / global.maxfps)) }