audio_sound_pitch(m_mainmenu,1)
audio_sound_gain(m_mainmenu,global.musicvolume,1)
if !audio_is_playing(m_mainmenu) {
audio_play_sound(m_mainmenu,0,1);
}