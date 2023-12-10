show_debug_message("Level Reloading")

var directory = game_save_id + "/LevelEditor Files/" + "/" + global.levelname + "/"
scr_loadleveleditor()
global.LEBuild = 1
global.LES = 0
scr_LEChangeScenery()

if global.LELevelWidthBlocks = 32 {
if global.LELevelHeightBlocks = 22 {	
instance_destroy(o_smoothcamera)
}}


if !instance_exists(o_inputtext) {
instance_create(x,y,o_inputtext)
}
if instance_exists(o_inputtext) {
o_inputtext.text = global.leveleditorstring
keyboard_string = "";
global.writingmode = 0
}
audio_play_sound(snd_hitboss,0,0)
instance_destroy(o_player)
instance_destroy(o_enemyplayer)
instance_destroy(o_boredomblock)
instance_destroy(o_redparticle)
instance_destroy(o_yellowparticle)
instance_destroy(o_greenparticle)
instance_destroy(o_blueparticle)
instance_destroy(o_whiteparticle)
scr_leveleditormusic()



if directory_exists(directory) {
if !instance_exists(o_deathcounter) {
instance_create(x,y,o_deathcounter)
}
if !instance_exists(o_timecounter) {
instance_create(x,y,o_timecounter)
}
if !instance_exists(o_time) {
instance_create(x,y,o_time)
}}

depth = -700
global.naminglevel = false
global.LEVerified = 0


alarm[1] = 1