if global.challenges = 0 {
if room != r_leveleditor {
if global.hardmode = 0 {
global.pickup = 1
global.totalcoins += 1
if global.totalcoins = 5000 {
global.skin[13] = 1
scr_saveskins()
}
global.special += 1
}
if global.hardmode = 1 {
global.hardmodelives += 1
global.total1ups += 1
}
}}
audio_play_sound(snd_coin,5,0)
instance_destroy();
if global.itempar = 1 { repeat (irandom_range(3,7)) { var star = instance_create(x+16,y+16,o_itemstar);
	with star { image_blend = c_yellow vib = 1 }} }
if global.hardmodedifficulty = 6 { global.timeleftHM += 2 }

//Narrator
if room = r_lvl6 { o_narrator.l = 0	}
if room = r_lvl7 { o_narrator.l = 0	}
if room = r_lvl8 { o_narrator.l = 0	}
if room = r_lvl9 { o_narrator.l = 0	}
if room = r_lvl10 { o_narrator.l = 0 }