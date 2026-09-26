if !audio_is_playing(m_mainmenu) {
audio_play_sound(m_mainmenu,0,1)
}
set_rich_presence()

if platform_touch() {
ads_show_banner(true)
}
