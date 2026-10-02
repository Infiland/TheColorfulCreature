if (!timing_instance_step()) exit;
if global.talelistened = 0 {
if place_meeting(x,y,o_player) {
room_goto(r_tale)
instance_destroy(o_star)
global.talelistened = 1
}
}