function music2bugfix() {
	musicandsoundvolumefix()
	if global.endless = 0 {
	if global.hardmode = 0 {
	rousr_dissonance_set_details("Story Mode - World 2") }
	else { rousr_dissonance_set_details("Hard Mode - World 2") }
	if !audio_is_playing(m_owthespikes) {
	audio_play_sound(m_owthespikes,0,1);	
	}}
}
