audio_stop_sound(m_corruptedworld)
audio_stop_sound(m_breakfromcorruption)
audio_stop_sound(m_lesscorruption)

rousr_dissonance_set_details("Story Mode - End of World 4")

scr_saveskins()
if !audio_is_playing(m_bossprepare) {
audio_play_sound(m_bossprepare,0,1)
}