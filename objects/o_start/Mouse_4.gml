/// @description Click to start
window_set_cursor(cr_default)
if room = r_mainmenu {
audio_sound_pitch(m_mainmenu,1)	
room_goto(r_gamemode);
hidehud()
}

if !instance_exists(o_progressask) {
if !instance_exists(o_quitask) {
if room = r_gamemode {
var directory = working_directory + "/Save Files/"
if file_exists(directory + "SaveFile.sav") {
instance_create(-1000,0,o_progressask)
} else {
startnewgame()
}
}
}}