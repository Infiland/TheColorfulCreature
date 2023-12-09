if locked = 0 {
if !instance_exists(o_quitask) {
room_goto(r_donolvl1);
global.challenges = 1
loadhud()
window_set_cursor(cr_default)
}}