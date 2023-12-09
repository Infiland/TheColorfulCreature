rousr_dissonance_set_details("In Level Select Menu")
rousr_dissonance_set_timestamps(undefined,undefined)

if !audio_is_playing(m_mainmenu) {
audio_play_sound(m_mainmenu,0,1)
}

if os_type = os_android {
AdMob_Banner_Create(AdMob_Banner_SMART,true)
AdMob_Banner_Show()
}