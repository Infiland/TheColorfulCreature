if !instance_exists(o_quitask) {
room_goto(r_stats)
window_set_cursor(cr_default)
audio_sound_pitch(m_mainmenu,1)	
audio_sound_gain(m_mainmenu,global.musicvolume,1)	
scr_loadstats()
rousr_dissonance_set_details("Checking Stats")
}