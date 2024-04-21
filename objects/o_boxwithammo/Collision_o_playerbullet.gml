audio_play_sound(snd_shooter,10,0)
if !instance_place(x,y,o_ammo) {
instance_create(x,y,o_ammo)
}
if room != r_leveleditor {
	increase_stat("totaldestroyedboxes","QUESTdestroyedboxes",1)
}
instance_destroy()