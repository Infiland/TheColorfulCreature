function music5bugfix() {
	musicandsoundvolumefix()
	if global.endless = 0 {
		if global.hardmode = 0 { 
	rousr_dissonance_set_details("Story Mode - World 5") }
	else { rousr_dissonance_set_details("Hard Mode - World 5") }
	if !audio_is_playing(m_thecastle) {
	audio_play_sound(m_thecastle,0,1);	
	}}


}
