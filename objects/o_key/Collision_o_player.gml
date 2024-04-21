if room != r_leveleditor { 
	increase_stat("totalkeypickups","QUESTkeypickups",1)
	}

instance_destroy()
audio_play_sound(snd_key,5,0);