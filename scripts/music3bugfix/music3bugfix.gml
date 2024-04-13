function music3bugfix() {
	musicandsoundvolumefix()
	if global.endless = 0 {
	audio_stop_sound(m_somethingswrong)
	if !audio_is_playing(m_everythingismoving) {
	audio_play_sound(m_everythingismoving,0,1);	
	}}


}
