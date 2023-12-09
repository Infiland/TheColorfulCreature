if room != r_leveleditor { 
	global.totalkeypickups += 1
	}

instance_destroy()
audio_play_sound(snd_key,5,0);