//Play Main Menu song
if room = r_loading {
if !audio_is_playing(m_mainmenu) {
audio_play_sound(m_mainmenu,0,1)
}
audio_sound_gain(m_mainmenu,global.musicvolume,100)
}

platform_touch_defaults();
if (platform_mobile()) scr_loadandroid();

room_goto(r_mainmenu)

instance_create(x,-500,o_newsbanner)
//Load Languages
switchlang()
//Load Anticheat
scr_anticheat()
