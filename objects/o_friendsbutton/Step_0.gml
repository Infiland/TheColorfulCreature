if (!timing_instance_step()) exit;
/// @description Show how many friends are playing right now

refresh_timer -= 1
if (refresh_timer <= 0) {
	refresh_timer = 120
	friends_playing = array_length(net_friends_list())
	text = friends_playing > 0 ? label + " (" + string(friends_playing) + ")" : label
}
