if steam_get_app_id() = 1749610 {
if !instance_exists(o_demoask) {instance_create(x,y,o_demoask)}
exit;
}

if !instance_exists(o_progressask) {
if !instance_exists(o_quitask) {
var directory = working_directory + "/Save Files/"
if file_exists(directory + "SaveFile.sav") {
window_set_cursor(cr_default)
audio_sound_pitch(m_mainmenu,1)
musicandsoundvolumefix()
global.hardmode = 0
global.challenges = 0
global.endless = 0

//Achievements
	if global.isgrayscale = true {
	if global.colorblindsettings != 4 {
	if room != r_settings {
	global.isgrayscale = false
	scr_saveachievements()
	}}}
	
	if global.isinvisible = true {
	if global.skinselected != 35 || global.hatselected != 0 {
	global.isinvisible = false
	scr_saveachievements()
	}}

scr_loadgame()
rousr_dissonance_set_timestamps(0,undefined)
audio_stop_sound(m_mainmenu);
scr_loadsettings()
o_narrator.l = 0
if global.musicvolume < 0.01 {
if room = r_easteregg1 {
audio_stop_sound(m_warp)	
}}
audio_stop_sound(m_mainmenu);
}
}}