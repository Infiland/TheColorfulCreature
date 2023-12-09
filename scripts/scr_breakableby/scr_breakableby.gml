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
}}}

}