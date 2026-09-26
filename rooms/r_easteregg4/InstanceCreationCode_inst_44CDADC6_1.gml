grv = 0.172
vsp = -15

audio_stop_sound(m_thecastle);
if !audio_is_playing(m_forthefans) {
audio_play_sound(m_forthefans,0,0)
}

if !achievement_earned("EASTEREGG_4") { achievement_award("EASTEREGG_4") }
