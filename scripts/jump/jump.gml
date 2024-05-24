function jump() {
	if object_index = o_player || object_index = o_playerMU {
	if global.noclip = 0 {
	if global.writingmode = 0 {
	if inwater = 1 {
	coyotetime = 0
	vsp = (-10 - (doublejump * 0.1)) 
	/*switch(global.maxfps) {
	case(60): vsp = -10 - (doublejump * 0.1) break;
	case(75): vsp = -10.01 - (doublejump * 0.1) break;
	case(100): vsp = -10.01 - (doublejump * 0.1) break;
	case(120): vsp = -10.1 - (doublejump * 0.1) break;
	case(144): 
	switch(grv) {
	default: vsp = -10.12 - (doublejump * 0.1) break;
	case(0.83): vsp = -10.5 - (doublejump * 0.1) break;
	} break;
	case(150): 
	switch(grv) {
	default: vsp = -10.135 - (doublejump * 0.1) break;
	case(0.83): vsp = -10.53 - (doublejump * 0.1) break;
	} 	break;
	
	}*/
	}
	if inwater = 2 {
	switch(global.maxfps) {
	case(60): vsp = -8 break;
	case(75): vsp = -8.02 break;
	case(100): vsp = -8.015 break;
	case(120): vsp = -8.05 break;
	case(144): vsp = -8.04 break;
	case(150): vsp = -8.04 break;
	}
	}
	
	doublejump = 0
	if room != r_leveleditor {
	increase_stat("totaljumps","QUESTjump",1)
	}}}}
	if object_index = o_enemyplayer {
	if !place_meeting(x,y-32,o_anyblock) {
	vsp = -10.5
	onground = 0
		audio_sound_pitch(snd_enemyjump,random_range(0.6,0.8));
		if distance_to_object(o_player) > 250 {
	   audio_sound_gain(snd_enemyjump,0,1)
		} else {
		audio_sound_gain(snd_enemyjump,global.soundvolume,1)
		}
		if distance_to_object(o_player) < 250 {
		if !audio_is_playing(snd_enemyjump) {
		audio_play_sound(snd_enemyjump,5,0)
		}}
	}}
if global.playerpar = 2 {
	if global.noclip = 0 {
/*var pmin = 4
var pmax = 7

if place_meeting(x,y-32,o_anyblock) { 
	pmin = 1
	pmax = 3
	}

repeat(irandom_range(pmin,pmax)) {par_walk = instance_create(x+14,y+27,o_parwalk)
with(par_walk) { jumped = 1 }
}*/
//instance_create(x+16,y+32,o_partjumpspawn)
/*var par = part_system_create(ps_redblockjump)
part_system_position(par,x+16,y+32)*/
}}

}