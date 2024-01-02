grv = 0.172
vsp = -15

audio_stop_sound(m_thecastle);
if !audio_is_playing(m_forthefans) {
audio_play_sound(m_forthefans,0,0)
}

if !steam_get_achievement("EASTEREGG_4") { steam_set_achievement("EASTEREGG_4") }	