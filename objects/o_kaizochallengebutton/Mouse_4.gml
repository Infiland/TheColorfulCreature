if locked = 0 {
if steam_get_app_id() = 1749610 {
if !instance_exists(o_demoask) {instance_create(x,y,o_demoask)}
exit
}
room_goto(r_kaizolvl1)

global.challenges = 1
loadhud()
global.DiamondMedalTimeChallenge = diamondtime
audio_stop_sound(m_mainmenu)
global.currentchallenge = challenge
audio_play_sound(m_funmodelevels,0,1)
audio_sound_gain(m_funmodelevels,global.musicvolume,1)
}