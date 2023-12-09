function music4bugfix() {
	musicandsoundvolumefix()
	if global.endless = 0 {
		if global.hardmode = 0 { 
	rousr_dissonance_set_details("Story Mode - World 4") }
	else { rousr_dissonance_set_details("Hard Mode - World 4") }
	if !audio_is_playing(m_corruptedworld) {
	audio_play_sound(m_corruptedworld,0,1);	
	}
	if audio_is_playing(m_breakfromcorruption) {
		audio_stop_sound(m_breakfromcorruption);
	}}


}
