scr_playercontrolsconfig()

if global.pickup = 0 {
shake = 0	
}
if global.pickup = 1 {
shake = 1.5
}

controls_key_display(global.controlsskiplevel)

//Skip
if os_type != os_android {
key_skip = keyboard_check(ord(global.controlsskiplevel)) || (gamepad_button_check(0,gp_face4))
} else { 
	if instance_exists(o_buttonskipandroid) {
	key_skip = o_buttonskipandroid.image_index = 1;
	}}


if global.special >= reqcoin {
if global.pause = 0 {
if skip != "You can't skip\nthis level" {
if global.skiplevelholdsettings = 0 {
if skipcontrols = 0 { key_skip = keyboard_check_pressed(ord(global.controlsskiplevel)) } else { key_skip = keyboard_check_pressed(global.controlsskiplevel) }
timer = -0.1
} else {
if global.skiplevelholdsettings = 0 {
if skipcontrols = 0 { key_skip = keyboard_check(ord(global.controlsskiplevel)) } else { key_skip = keyboard_check(global.controlsskiplevel) }
}
if key_skip { timer -= 1 / room_speed } else { timer = 0.7 }
	}
}
/*if global.skiplevelholdsettings = 0 {
	key_skip = keyboard_check_pressed(ord(global.controlsskiplevel))
	timer = -0.1
	} else {
key_skip = keyboard_check(ord(global.controlsskiplevel))
if key_skip { timer -= 1 / room_speed }
}*/
}} else {
if key_skip { 
	if !steam_get_achievement("UH_OH") { steam_set_achievement("UH_OH") }
}
}

if room != r_boss1 {
if room != r_boss1prepare {
if room != r_boss2 {
if room != r_boss2prepare {
if room != r_boss3 {
if room != r_boss3prepare {
if room != r_boss4prepare {
if room != r_boss4 {
if room != r_easteregg1 {
if room != r_easteregg2 {
if room != r_easteregg3 {
if room != r_truelvl100_p1 {
if room != r_truelvl100_p2 {
if room != r_boss5 {
if room != r_tale {
if global.pause = 0 {
if timer < 0 {
if key_skip {
if global.special >= reqcoin {
increase_stat("totalskips","QUESTskip",1)
if !steam_get_achievement("BYE_BYE_LEVEL") { steam_set_achievement("BYE_BYE_LEVEL") }

if room = asset_get_index("r_lvl" + string(global.worldProgression)) {
global.worldProgression += 1
}

scr_savestats()
scr_resetcheckpointdata()
if global.endless = 0 { room_goto_next() }
timer = 0.5
o_narrator.l = 0
global.pickup = 0
global.special -= reqcoin
}}}}}}}}}}}}}}}}}}}