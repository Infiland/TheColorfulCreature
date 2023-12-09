depth = -11000
scr_custombutton()

if room = r_gamemode {
audio_stop_sound(m_justonline)
}
if room = r_funmodemenu {
audio_sound_gain(m_justonline,0,1000)	
}