if !instance_exists(o_progressask) {
window_set_cursor(cr_default)
if room = r_gamemode {
room_goto(r_funmodemenu)
global.challengescroll = 0
scr_saveskins()
audio_sound_gain(m_mainmenu,0,1000)
}}