randomize();

if global.itempar = 1 { 
	repeat (irandom_range(3,7)) {
 var star = instance_create(x+16,y+16,o_itemstar)
	with star { image_blend = c_aqua }
	}
	}

instance_destroy();
if room != r_leveleditor { global.totaldjumppickups += 1}