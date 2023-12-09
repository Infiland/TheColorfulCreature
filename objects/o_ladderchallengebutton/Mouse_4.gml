if locked = 0 {
room_goto(r_ladderlvl1)
global.DiamondMedalTimeChallenge = diamondtime
rousr_dissonance_set_timestamps(0,undefined)
rousr_dissonance_set_details("Playing Ladder Challenge")
global.challenges = 1
loadhud()
audio_stop_sound(m_mainmenu)
global.currentchallenge = challenge
audio_play_sound(m_owthespikes,0,1)
audio_sound_gain(m_owthespikes,global.musicvolume,1)
}