if global.LEBuild = 1 {
audio_play_sound(snd_coin,5,0)

instance_destroy();
repeat (irandom_range(3,7)) { var star = instance_create(x+16,y+16,o_itemstar);
	with star { image_blend = c_yellow }}
}