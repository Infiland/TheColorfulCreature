function restartchallenge(){
if global.challenges = 1 {
switch(global.currentchallenge) {
default: challenge = r_tutoriallvl1 break;
case(1): challenge = r_kaizolvl1 break;
case(2): challenge = r_blindlvl1 break;
case(3): challenge = r_bigroomlvl1 break;
case(4): challenge = r_trooplvl1 break;
case(5): challenge = r_slipperylvl1 break;
case(6): challenge = r_speedlvl1 break;
case(7): challenge = r_world6lvl1 break;
case(8): challenge = r_ladderlvl1 break;
//NO CHALLENGE 9, NOT A BUG!
case(10): challenge = r_spikelvl1 break;
case(11): challenge = r_waterlvl1 break;
case(12): challenge = r_movinglvl1 break;
case(13): challenge = r_communitylvl1 break;
case(14): challenge = r_djlvl1 break;
case(15): challenge = r_cslvl1 break;
case(16): challenge = r_world7lvl1 break;
case(17): challenge = r_invisiblelvl1 break;
case(18): challenge = r_breakablelvl1 break;
}
resetgeneral()
room_goto(challenge)
audio_group_set_gain(Music,global.musicvolume,1000)
}}