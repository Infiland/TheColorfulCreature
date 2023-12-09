function music1bugfix() {
	musicandsoundvolumefix()
	if global.endless = 0 {
	if global.hardmode = 0 { 
	rousr_dissonance_set_details("Story Mode - World 1") }
	else { rousr_dissonance_set_details("Hard Mode - World 1") }
	if !audio_is_playing(m_basics) {
	audio_play_sound(m_basics,0,1);	
	}}


}
