if locked = 0 {
rousr_dissonance_set_timestamps(0,undefined)
rousr_dissonance_set_details("Playing Big Room Challenge")
room_goto(r_bigroomlvl1)
global.DiamondMedalTimeChallenge = diamondtime
global.challenges = 1
loadhud()
audio_stop_sound(m_mainmenu)
global.currentchallenge = challenge
audio_play_sound(m_funmodelevels3,0,1)
audio_sound_gain(m_funmodelevels3,global.musicvolume,1)
}