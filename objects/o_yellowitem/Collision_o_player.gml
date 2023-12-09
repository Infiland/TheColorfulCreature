instance_destroy()
audio_play_sound(snd_pickup,5,0);

if global.itempar = 1 { instance_create(x+16,y+16,o_yellowpickup) }
if room != r_leveleditor { 
	global.totalnormalpickups += 1
	}