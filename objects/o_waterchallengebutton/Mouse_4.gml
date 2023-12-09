if locked = 0 {
if steam_get_app_id() = 1749610 {
if !instance_exists(o_demoask) {instance_create(x,y,o_demoask)}
exit
}
room_goto(r_waterlvl1)
global.DiamondMedalTimeChallenge = diamondtime
rousr_dissonance_set_timestamps(0,undefined)
rousr_dissonance_set_details("Playing Water Challenge")
global.challenges = 1
loadhud()
audio_stop_sound(m_mainmenu)
global.currentchallenge = challenge
audio_play_sound(m_underwater,0,1)
audio_sound_gain(m_underwater,global.musicvolume,1)
}