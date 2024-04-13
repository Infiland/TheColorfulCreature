function music1bugfix() {
	musicandsoundvolumefix()
	if global.endless = 0 {
	if !audio_is_playing(m_basics) {
	audio_play_sound(m_basics,0,1);	
	}}
}