if locked = 0 {

room_goto(r_bigroomlvl1)
global.DiamondMedalTimeChallenge = diamondtime
global.challenges = 1
loadhud()
audio_stop_sound(m_mainmenu)
global.currentchallenge = challenge
audio_play_sound(m_funmodelevels3,0,1)
audio_sound_gain(m_funmodelevels3,global.musicvolume,1)
}