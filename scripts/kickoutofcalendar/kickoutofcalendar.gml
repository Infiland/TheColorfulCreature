function kickoutofcalendar(){
		room_goto(r_calendar)
		window_set_cursor(cr_default)
		hidehud()
		audio_stop_all()
if !audio_is_playing(m_mainmenu) {
audio_play_sound(m_mainmenu,0,1)
}

audio_sound_gain(m_mainmenu,global.musicvolume,1000)
}