if !audio_is_playing(m_credits) {
audio_play_sound(m_credits,0,1)
}
audio_sound_gain(m_mainmenu,0,2000)	
audio_sound_gain(m_goodending,0,2000)
audio_sound_gain(m_credits,global.musicvolume,2000)