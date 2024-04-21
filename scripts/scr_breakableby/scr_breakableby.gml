function scr_breakableby(object){
var _dt = (60 / global.maxfps)


if instance_exists(object) {
if (object.vsp) >= 0 {
if place_meeting(x,(y-(object.vsp)-1),object) {
hpbreakable -= (1 + (object.vsp) * 4) * _dt
}}
if (object.vsp) <= 0 {
if place_meeting(x,(y-(object.vsp)+1),object) {
hpbreakable -= (1 - (object.vsp) * 4) * _dt
}}

}



if hpbreakable < 0 {
if room != r_leveleditor {
if instance_exists(o_player) {
if place_meeting(x,(y-(o_player.vsp)-10),o_player) || place_meeting(x,(y+(o_player.vsp)+10),o_player) {
o_player.vsp = 0
increase_stat("totalblocksbroken","QUESTblocksbroken",1)	
}}}
instance_destroy()
}

}