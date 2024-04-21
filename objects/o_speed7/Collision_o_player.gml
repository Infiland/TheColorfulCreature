randomize()
audio_sound_pitch(snd_speed,random_range(0.9,1.1));
audio_play_sound(snd_speed,10,0)
instance_destroy()
if global.itempar = 1 { 
	repeat (irandom_range(3,7)) {
 var star = instance_create(x+16,y+16,o_itemstar)
	with star { image_blend = c_orange vib = 1 }
	}
	}

if room != r_leveleditor { 
	increase_stat("totalspeedpickups","QUESTspeedpickups",1)
	}