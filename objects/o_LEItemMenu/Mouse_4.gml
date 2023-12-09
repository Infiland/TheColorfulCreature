if instance_exists(o_leveleditorleaveask) { exit }

//if instance_exists(o_namelevelLE) { exit }
audio_play_sound(snd_hitboss,0,0)
if !instance_exists(o_itemmenuLE) {
instance_create(x,y,o_itemmenuLE)
} else { instance_destroy(o_itemmenuLE)
	instance_destroy(o_LELiquid)
	instance_destroy(o_LEBackground)
	instance_destroy(o_LEBuild)
	instance_destroy(o_itemmenuselectLE)
	}

depth = -700