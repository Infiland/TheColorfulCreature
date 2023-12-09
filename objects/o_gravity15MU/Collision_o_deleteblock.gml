if global.LEBuild = 1 {
if global.sound = 1 {
	randomize();
audio_sound_pitch(snd_gravity,random_range(0.9,1.1));
audio_play_sound(snd_gravity,10,0)
}
instance_destroy()
repeat (irandom_range(3,7)) instance_create(x+16,y+16,o_gravitystar);
}