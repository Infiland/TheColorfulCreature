if global.pause = 1 { exit }

if cannontroopspawn > 0 {
if y = 0 {

direction = lerp(direction,dir,0.1 * (60 / global.maxfps))

if global.hardmode = 0 {
if onplayer = 0 {
if instance_exists(o_player) {
dir = point_direction(x,y,o_player.x+16,o_player.y+16)
}
if floor(dir) = floor(direction) {
onplayer = 1	
}}
} else { 
if instance_exists(o_player) {
dir = point_direction(x,y,o_player.x+16,o_player.y+16)
}
	onplayer = 1 }

if troopshoot = 0 {
if onplayer = 1 {

if global.hardmode = 0 { 
yscale -= 0.01 * (60 / global.maxfps)
} else { yscale -= 0.02 * (60 / global.maxfps) }	

if yscale < 0.8 {
troopshoot = 1
cannontroopspawn -= 1
var troop = instance_create(x+16,y+100,o_enemytroopprojectileboss5)
audio_play_sound(snd_rocket,0,0,0.5)
with troop {
if o_bigcannonboss5.armoredtrooplimit > 0 {
if global.hardmode = 0 { 
hpproj = choose(1,1,1,1,1,1,3)
}
if global.hardmode = 1 { 
hpproj = choose(1,1,1,1,1,3,3,1,1,1,1,1,1,1,1,3,5)
}
if hpproj > 1 {
o_bigcannonboss5.armoredtrooplimit -= 1
}} else {
hpproj = 1
}
}

}
}


}

if troopshoot = 1 {
if yscale > 1 {
troopshoot = 0
onplayer = 0
} else {
if global.hardmode = 0 { 
yscale += 0.02 * (60 / global.maxfps)
} else { yscale += 0.04 * (60 / global.maxfps) }	
}}
}

if y < 0 {
y += 1 * (60 / global.maxfps)
if y > 0 {y = 0	}
}}

if cannontroopspawn < 1 {
y -= 1 * (60 / global.maxfps)
if y < -200 { instance_destroy() }
if yscale < 1 {
	yscale += 0.02 * (60 / global.maxfps)
}

with(o_kingboss) {
state = 1
vsp = -20
hsp = -5
x = 2144
y = 640
timerjump = 120
timercannon = irandom_range(7,10)
depth = -99
}}