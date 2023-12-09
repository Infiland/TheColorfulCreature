if global.pause = 0 {
if global.hardmode = 0 {
if littlepause = 0 {
if hp = 3 {	
instance_create(x,y,o_ketchup)
}
if hp = 2 {
randomketchup = irandom_range(0,2)
if randomketchup = 0 { instance_create(x,y,o_mayonese) }
else
instance_create(x,y,o_ketchup)
}

if hp = 1 {
global.boss1finalattack = 1
randomketchup = irandom_range(0,3)
specialattackboss1 = irandom_range(0,4)
if randomketchup = 0 {
if specialattackboss1 = 0 { 
	instance_create(x,y,o_giantmayonese) 
	} else {
instance_create(x,y,o_mayonese)		
	}
}
else {
instance_create(x,y,o_ketchup)	
}

if hp > 1 {
timer = irandom_range(30,40)
image_xscale = 1.05;
image_yscale = 1.05;
alarm[2] = 3
}
if hp = 1 {
timer = irandom_range(24,34)
image_xscale = 1.05;
image_yscale = 1.05;
alarm[2] = 3
}
}
//Hard Mode
if global.hardmode = 1 {
if littlepause = 0 {
if hp = 3 {
randomketchup = irandom_range(0,15)
	randomketchup2 = irandom_range(0,1)
if randomketchup = 15 { alarm[3] = 10 }
else
instance_create(x,y,o_ketchup)
}
if hp = 2 {
randomketchup = irandom_range(0,1)
if randomketchup = 0 { instance_create(x,y,o_mayonese) }
else
instance_create(x,y,o_ketchup)
}

if hp = 1 {
global.boss1finalattack = 1
randomketchup = irandom_range(0,3)
if randomketchup = 0 { instance_create(x,y,o_mayonese) }
if randomketchup = 1 { instance_create(x,y,o_ketchup) }
if randomketchup = 2 { alarm[3] = 12
	randomketchup2 = irandom_range(0,1)
	instance_create(x,y,o_mayonese) }
}
}
if hp > 1 {
alarm[0] = irandom_range(30,40)
image_xscale = 1.05;
image_yscale = 1.05;
alarm[2] = 2
}
if hp = 1 {
alarm[0] = irandom_range(26,34)
image_xscale = 1.05;
image_yscale = 1.05;
alarm[2] = 2
}}}}}