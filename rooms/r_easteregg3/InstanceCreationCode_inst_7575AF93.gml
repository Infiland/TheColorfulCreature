if !audio_is_playing(m_blocktension) {
audio_play_sound(m_blocktension,0,1)
audio_stop_sound(m_corruptedworld)
}

if !steam_get_achievement("EASTEREGG_3") { steam_set_achievement("EASTEREGG_3") }	