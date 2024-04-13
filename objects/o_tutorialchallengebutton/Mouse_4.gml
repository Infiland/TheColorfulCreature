if locked = 0 {
room_goto(r_tutoriallvl1)

global.challenges = 1
global.DiamondMedalTimeChallenge = diamondtime
loadhud()
audio_stop_sound(m_mainmenu)
global.currentchallenge = challenge
audio_play_sound(m_heaven,0,1)
audio_sound_gain(m_heaven,global.musicvolume,1)
}