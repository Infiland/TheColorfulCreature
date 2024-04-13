if locked = 0 {
room_goto(r_breakablelvl1)
global.DiamondMedalTimeChallenge = diamondtime

global.challenges = 1
loadhud()
audio_stop_sound(m_mainmenu)
global.currentchallenge = challenge
audio_play_sound(m_blocktension,0,1)
audio_sound_gain(m_blocktension,global.musicvolume,1)
}