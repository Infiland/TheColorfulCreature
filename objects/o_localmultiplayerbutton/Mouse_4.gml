if steam_get_app_id() = 1749610 {
if !instance_exists(o_demoask) {instance_create(x,y,o_demoask)}
exit
}

if room = r_funmodemenu {
global.customizeselectMU = 1
room_goto(r_localmultiplayermenu);
rousr_dissonance_set_details("Preparing for Local Multiplayer")
audio_sound_gain(m_mainmenu,0,1000)
if !audio_is_playing(m_justonline) {
audio_play_sound(m_justonline,0,1)
}
audio_sound_gain(m_justonline,global.musicvolume,1000)
}