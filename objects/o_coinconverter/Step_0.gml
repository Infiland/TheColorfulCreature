scr_playercontrolsconfig()

if global.levelselect = 0 {

if os_type != os_android {
if interactcontrols = 0 {
key_interact = keyboard_check_pressed(ord(global.controlsinteract))
} else { key_interact = keyboard_check_pressed(global.controlsinteract) }} else {
	if instance_exists(o_buttoninteractandroid) {
	key_interact = o_buttoninteractandroid.image_index = 1;
	}
}

if instance_place(x,y,o_player) {
if !instance_exists(o_creditscounter) {
instance_create(x,y,o_creditscounter)	
}} else {
instance_destroy(o_creditscounter)
}

if global.special != 0 {
if key_interact {
if used = false {
if global.checkdeposit = false {
global.creditscurrency += floor(global.special * (5 + (global.special * 0.01)))
audio_play_sound(snd_cashsound,0,0)
if global.skin020 = 0 {
if global.special = 100 {
global.skin020 = 1
}}
global.special = 0
global.pickup = 0
global.checkdeposit = true
used = true
scr_savegame()
}}}}}