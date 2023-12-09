global.level100trap = 0
if global.music = 1 {
if global.endless = 0 {
if !audio_is_playing(m_heartbeat) {
audio_play_sound(m_heartbeat,0,1);	
}}}