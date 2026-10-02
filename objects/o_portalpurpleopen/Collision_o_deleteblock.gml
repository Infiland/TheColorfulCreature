if (!timing_is_tick()) exit;
if global.LEBuild = 1 {
tcc_randomize();
repeat (irandom_range(3,7)) { var star = instance_create(x+16,y+16,o_itemstar);
	with star { image_blend = c_fuchsia }
}
instance_destroy()
audio_sound_pitch(snd_portal,random_range(0.9,1.1));
audio_play_sound(snd_portal,-2,0);
}