rousr_dissonance_set_details("In Fun Mode")
steam_set_rich_presence("Menu","In Fun Mode")

if !audio_is_playing(m_mainmenu) {
audio_play_sound(m_mainmenu,0,1)
}
audio_sound_gain(m_mainmenu,global.musicvolume,1000)
global.diamondmedalcount = 0
global.perfectscorecount = 0

AdMob_Banner_Hide()