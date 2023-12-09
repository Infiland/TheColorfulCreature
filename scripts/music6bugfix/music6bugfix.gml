function music6bugfix() {
	musicandsoundvolumefix()
	if global.endless = 0 {
	rousr_dissonance_set_details("Story Mode - World 4")
	if audio_is_playing(m_corruptedworld) {
	audio_stop_sound(m_corruptedworld);	
	}
	if !audio_is_playing(m_breakfromcorruption) {
		audio_play_sound(m_breakfromcorruption,0,1);
	}}


}
