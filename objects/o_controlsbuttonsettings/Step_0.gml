if global.choosesettings != 3 { 
x = lerp(x,camera_get_view_x(view_camera[0])-256,0.2 * (60 / global.maxfps))
	editcontrols = -1
	}
if global.choosesettings = 3 { x = lerp(x,camera_get_view_x(view_camera[0])+32,0.2 * (60 / global.maxfps)) }

if global.choosesettings = 3 {
	if keyboard_check_pressed(vk_anykey) and string_length(keyboard_string) < 2 {
	controlschoose = keyboard_string
	
	if keyboard_check_pressed(vk_down) { controlschoose = "40" }
	if keyboard_check_pressed(vk_right) { controlschoose = "39" }
	if keyboard_check_pressed(vk_up) { controlschoose = "38" }
	if keyboard_check_pressed(vk_left) { controlschoose = "37" }
	if keyboard_check_pressed(vk_space) { controlschoose = "32" }
	if keyboard_check_pressed(vk_control) { controlschoose = "17" }
	if keyboard_check_pressed(vk_enter) { controlschoose = "13" }
	if keyboard_check_pressed(vk_shift) { controlschoose = "16" }
	if keyboard_check_pressed(vk_tab) { controlschoose = "9" }
	if keyboard_check_pressed(vk_alt) { controlschoose = "18" }
	if keyboard_check_pressed(ord(",")) { controlschoose = "188" }
	if keyboard_check_pressed(ord(".")) { controlschoose = "190" }
	if keyboard_check_pressed(ord("/")) { controlschoose = "191" }
	if keyboard_check_pressed(vk_escape) { controlschoose = "27" }
	if keyboard_check_pressed(vk_backspace) { controlschoose = "8" }

	keyboard_string = ""
	if instance_exists(o_settingspausemenu) {
	global.isreversed = true
	scr_saveachievements()
	}
	switch(editcontrols) {
	case(0): global.controlsmoveright = controlschoose break;
	case(1): global.controlsmoveleft = controlschoose break;
	case(2): global.controlsjump = controlschoose break;
	case(3): global.controlsinteract = controlschoose break;
	case(4): global.controlsskiplevel = controlschoose break;
	case(5): global.controlsrestart = controlschoose break;
	}
	global.controlsjump = string_upper(global.controlsjump)
	global.controlsmoveright = string_upper(global.controlsmoveright)
	global.controlsmoveleft = string_upper(global.controlsmoveleft)
	global.controlsinteract = string_upper(global.controlsinteract)
	global.controlsskiplevel = string_upper(global.controlsskiplevel)
	global.controlsrestart = string_upper(global.controlsrestart)

	ischanging = false
	editcontrols = -1
	}	
}