if global.LEBuild = 1 {
	randomize();
audio_sound_pitch(snd_zerogravity,random_range(0.9,1.1));
audio_play_sound(snd_zerogravity,10,0)

instance_destroy()
repeat (irandom_range(3,7)) { var star = instance_create(x+16,y+16,o_itemstar);
	with star { image_blend = c_fuchsia }
}
}