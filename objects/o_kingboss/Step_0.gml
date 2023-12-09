randomize()

if global.pause = 1{ exit }

//Health
if hp <= 0 {
instance_destroy()
instance_create(x,y,o_kingbossdead)
audio_stop_sound(m_kingsthrone)
audio_play_sound(snd_dead,5,0)
}

//Movement
if instance_exists(o_player) {
switch(state) {	
case(0):
if o_player.x > 1500 {
vsp = -20
state = 1
global.checkpointX = 1501
global.checkpointY = 608
if global.hardmode = 1 {
global.checkpointAMMO = 24
} else { global.checkpointAMMO = 48 }
if !audio_is_playing(m_kingsthrone) {
audio_stop_sound(m_kingintro)	
audio_play_sound(m_kingsthrone,0,1)	
}
}
break;
case(1):
x -= 5 * (60 / global.maxfps)
if x < 1800 {
if global.berserk = 1 {
hp = 0	
}
state = 2
depth = -1
hsp = -5
}
break;

case(2):
if hsp = -5 {
if x < 1144 {
hsp = 5
}} else {
if x > 1929 {
hsp = -5
}}

timerjump -= 1 * (60 / global.maxfps)

if timerjump < 0 {
vsp = -15
timerjump = irandom_range(120,150)
timercannon -= 1

if timercannon = 0 {
state = 3
depth = -99
}
}


break;
case(3):
if !instance_exists(o_bigcannonboss5) {
instance_create(1504,-200,o_bigcannonboss5)	
}
break;
}} else {
	timerjump = 21
if hsp = -5 {
if x < 1144 {
hsp = 5
}} else {
if x > 1929 {
hsp = -5
}}	
}

//Animation
if hsp > 0 {
image_index = 1
} else {
image_index = 0	
}

//Collision
if state != 0 {
vsp = vsp + (grv * (60 / global.maxfps))

if state != 1 {
if state != 3 {
	if (place_meeting(x,y+vsp,o_anyblock)) {
	    while (!place_meeting(x,y+sign(vsp),o_anyblock)) 
	    {
	        y = y + sign(vsp);
	    }
	    vsp = 0;
	}

	/*if (place_meeting(x+hsp,y,o_anyblock)) {
	    while (!place_meeting(x+sign(hsp),y,o_anyblock)) 
	{
	x = x + sign(hsp);
	}
	hsp = 0;
	}*/
}}

if vsp > 30 * (global.maxfps / 60) { vsp = 30 * (global.maxfps / 60) }
	    if y > -200 {
		x = x + hsp * (60 / global.maxfps)
		y = y + vsp * (60 / global.maxfps)
		}
}