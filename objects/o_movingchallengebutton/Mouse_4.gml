if locked = 0 {
if steam_get_app_id() = 1749610 {
if !instance_exists(o_demoask) {instance_create(x,y,o_demoask)}
exit
}
global.DiamondMedalTimeChallenge = diamondtime
room_goto(r_movinglvl1)

global.challenges = 1
loadhud()
audio_stop_sound(m_mainmenu)
global.currentchallenge = challenge
audio_play_sound(m_everythingismoving,0,1)
audio_sound_gain(m_everythingismoving,global.musicvolume,1)
}