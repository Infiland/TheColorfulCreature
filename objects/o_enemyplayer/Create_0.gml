if global.berserk = 1 {
instance_destroy()	
}
randomize();

reactiontime = 25
hasammo = 0
state = 2
vsp = 0
hsp = 3
grv = 0.5 * (60/global.maxfps)
move = 0
rngjump = 0
boredchasing = 0
bored = 0
horizontal = 0
onground = 1
preparedforbullet = 0
troopsound = 0
amountofjumps = 0
inwater = 1
hp = 1

cansee = 0
deaf = 0
noreaction = 0

dontxrayfix = 1 //Dont xray fixed

/*
State = 0 - idle
State = 1 - Follow
State = 2 - full idle
*/

depth = 1
alarm[0] = 2