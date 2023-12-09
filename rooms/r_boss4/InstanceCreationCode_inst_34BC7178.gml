		if global.hardmode = 0 { 
	rousr_dissonance_set_details("Story Mode - Lava Boss") }
	else { rousr_dissonance_set_details("Hard Mode - Lava Boss") }
audio_stop_sound(m_bossprepare)
if global.boss4 = 0 {
if !audio_is_playing(m_lavatime) {
audio_play_sound(m_lavatime,0,1)
}
} else {
audio_stop_sound(m_lavatime)
instance_destroy(o_key)
if !audio_is_playing(m_bosswin) {
audio_play_sound(m_bosswin,0,0)
}
}