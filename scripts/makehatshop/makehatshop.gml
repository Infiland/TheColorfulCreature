function makehatshop(hatlock,cost,hat) {
	
if hatlock = 0 {
if global.creditscurrency >= cost {

audio_play_sound(snd_cashsound,0,0)
global.creditscurrency -= cost;
if !steam_get_achievement("FIRST_HAT") { //First Hat
 steam_set_achievement("FIRST_HAT") }
hatlock = 1
global.hat[hat] = 1
scr_savehats()
scr_savestats()

}}
}