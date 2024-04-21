if room != r_leveleditor {
	increase_stat("totaldestroyedboxes","QUESTdestroyedboxes",1)
}
audio_play_sound(snd_shooter,10,0)
instance_destroy() 