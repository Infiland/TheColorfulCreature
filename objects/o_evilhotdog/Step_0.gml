//Music
if room = r_boss1 {
if !audio_is_playing(m_hotdogtimephase1) and !audio_is_playing(m_hotdogtimephase2) and !audio_is_playing(m_hotdogtimephase3) {
switch(hp) {
case(3): audio_play_sound(m_hotdogtimephase1,0,0) break;
case(2): audio_play_sound(m_hotdogtimephase2,0,0) break;
case(1): audio_play_sound(m_hotdogtimephase3,0,0) break;
}}
}

if global.pause = 1 { exit }
if bosshit1 = 0 {
image_angle += animation
}
if direction_animation = 0 {
animation += 0.04 * (60 / global.maxfps) 
}
if direction_animation = 1 {
animation -= 0.04 * (60 / global.maxfps) 
}
if animation > 1 {
direction_animation = 1
}
if animation < -1 {
direction_animation = 0
}

if hp = 3 {
image_index = 0
}
if hp = 2 {
image_index = 1
}
if hp < 2 {
image_index = 2
}

if bosshit1 = 1 {
rotate += 1 * (60 / global.maxfps) 
if rotate < 19 {
image_angle += 20 * (60 / global.maxfps) 
}
if rotate > 19 {
bosshit1 = 0
}}

//Shooting
if room = r_boss1 {
if global.pause = 0 {
if littlepause = 0 {	
if global.hardmode = 0 {

if timer < 0 {
if hp = 3 {	
instance_create(x,y,o_ketchup)
}}

if timer < 0 {
if hp = 2 {
randomketchup = irandom_range(0,2)
if randomketchup = 0 { instance_create(x,y,o_mayonese) }
else
instance_create(x,y,o_ketchup)
}}

if timer < 0 {
if hp = 1 {
global.boss1finalattack = 1
randomketchup = irandom_range(0,3)
if global.deaths < 30 {
specialattackboss1 = irandom_range(0,2)
} else { specialattackboss1 = irandom_range(0,4) }
if randomketchup = 0 {
if specialattackboss1 = 0 { 
	instance_create(x,y,o_giantmayonese) 
	} else {
instance_create(x,y,o_mayonese)		
	}
}
else {
instance_create(x,y,o_ketchup)		
}}}

}
if global.hardmode = 1 {
if timer < 0 {
if hp = 3 {
randomketchup = irandom_range(0,15)
	randomketchup2 = irandom_range(0,1)
if randomketchup = 15 { alarm[3] = 10 }
else
instance_create(x,y,o_ketchup)
}}
if timer < 0 {
if hp = 2 {
randomketchup = irandom_range(0,1)
if randomketchup = 0 { instance_create(x,y,o_mayonese) }
else
instance_create(x,y,o_ketchup)	
}}
if timer < 0 {
if hp = 1 {
global.boss1finalattack = 1
randomketchup = irandom_range(0,4)
if randomketchup = 0 { instance_create(x,y,o_mayonese) }
if randomketchup = 1 { instance_create(x,y,o_ketchup) }
if randomketchup = 2 { alarm[3] = 12
randomketchup2 = irandom_range(0,1)
instance_create(x,y,o_mayonese) }	
if randomketchup = 3 { instance_create(x,y,o_giantmayonese) }
if randomketchup = 4 { instance_create(x,y,o_giantketchup) }
}}



}}}

//Reset Timer
if hp = 3 {
if timer < 0 {
timer = irandom_range(30,40)
image_xscale = 1.05;
image_yscale = 1.05;
alarm[2] = 3
}}

if hp = 2 {
if timer < 0 {
timer = irandom_range(28,36)
image_xscale = 1.05;
image_yscale = 1.05;
alarm[2] = 3
}}

if hp = 1 {
if timer < 0 {
timer = irandom_range(24,34)
image_xscale = 1.05;
image_yscale = 1.05;
alarm[2] = 3
}}
if global.pause = 0 {
timer -= 1 * (60 / global.maxfps)
}
}