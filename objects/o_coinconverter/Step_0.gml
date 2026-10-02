if (!timing_instance_step()) exit;
key_interact = false;
scr_playercontrolsconfig()

if global.levelselect = 0 {

key_interact = player_interact_pressed();

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
if global.skin[20] = 0 {
if global.special = 100 {
global.skin[20] = 1
}}
global.special = 0
global.pickup = 0
global.checkdeposit = true
used = true
scr_savegame()
}}}}}
