if instance_exists(o_progressask) { exit }
if !instance_exists(o_quitask) {
scr_loadachievements()
if os_type != os_android {
window_set_cursor(cr_default)
room_goto(r_achievements)
audio_sound_pitch(m_mainmenu,1)	
audio_sound_gain(m_mainmenu,global.musicvolume,1)	
} else {
if (!GooglePlayServices_IsSignedIn()) {
GooglePlayServices_StartSignInIntent();
}
GooglePlayServices_Achievements_Show()
}
}