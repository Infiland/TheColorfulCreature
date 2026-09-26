set_rich_presence()

if !audio_is_playing(m_mainmenu) { audio_play_sound(m_mainmenu,0,1) }
audio_sound_gain(m_mainmenu,global.musicvolume,1000)
global.currentchallenge = 0
global.diamondmedalcount = 0
global.perfectscorecount = 0
scr_savechallengetime()

if platform_touch() {
ads_show_banner(true)
}
