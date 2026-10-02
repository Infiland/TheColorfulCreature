troop_defeated = false
nav_path = []
if global.berserk = 1 {
instance_destroy()	
}
tcc_randomize();

reactiontime = 25
chase_direction = 0
high_jump_ticks = 0
hasammo = 0
state = 2
vsp = 0
hsp = 3
grv = 0.5 * (60/TCC_SIM_HZ)
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

// Pathfinding
climbing = 0
climb_target_y = 0
nav_path = []
nav_path_index = 0
// Instance IDs are typed references in current runtimes and cannot use mod.
// Position plus spawn count gives reproducible offsets, including coincident
// troops, without consuming gameplay RNG or depending on allocated IDs.
nav_stagger = floor(x) * 17 + floor(y) * 13 + instance_number(o_enemyplayer);
nav_recalc_timer = 1 + (((nav_stagger mod 31) + 31) mod 31)
nav_generation = -1
nav_ladder_id = noone

/*
State = 0 - idle
State = 1 - Follow
State = 2 - full idle
*/

depth = 1
alarm[0] = 2
