global.level100trap = 0
audio_stop_sound(m_thecastle)

if global.endless = 0 {
if !audio_is_playing(m_heartbeat) {
audio_play_sound(m_heartbeat,0,1);	
}}