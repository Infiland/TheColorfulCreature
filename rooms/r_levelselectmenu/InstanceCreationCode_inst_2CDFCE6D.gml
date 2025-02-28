if !audio_is_playing(m_mainmenu) {
audio_play_sound(m_mainmenu,0,1)
}

if os_type = os_android || os_type = os_gxgames {
AdMob_Banner_Create(AdMob_Banner_SMART,true)
AdMob_Banner_Show()
}