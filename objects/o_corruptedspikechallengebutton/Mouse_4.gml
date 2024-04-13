if locked = 0 {
if steam_get_app_id() = 1749610 {
if !instance_exists(o_demoask) {instance_create(x,y,o_demoask)}
exit
}
room_goto(r_cslvl1)
global.DiamondMedalTimeChallenge = diamondtime

global.challenges = 1
loadhud()
audio_stop_sound(m_mainmenu)
global.currentchallenge = challenge
audio_play_sound(m_somethingswrong,0,1)
audio_sound_gain(m_somethingswrong,global.musicvolume,1)
}