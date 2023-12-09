randomise();
audio_sound_pitch(snd_gravity,random_range(0.9,1.1));
audio_play_sound(snd_gravity,10,0)
instance_destroy();
if global.itempar = 1 { repeat (irandom_range(3,7)) var item = instance_create(x+16,y+16,o_itemstar)
	with(item) { image_blend = c_fuchsia }}