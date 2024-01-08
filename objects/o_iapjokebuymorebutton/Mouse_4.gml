if !instance_exists(o_progressask) {
room_goto(r_iapjoke)
var snd = audio_play_sound(m_dankmlgsong,0,1)
audio_sound_gain(snd,0,0)
audio_sound_set_track_position(snd,11)
audio_sound_gain(snd,global.musicvolume,1000)
window_set_cursor(cr_default)

global.lowoncreditsACH = 1
global.toomuchcreditsACH = 1
	
}