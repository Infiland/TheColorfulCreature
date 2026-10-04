if instance_exists(o_progressask) { exit }

if !instance_exists(o_quitask) && !instance_exists(o_friendspanel) {
	window_set_cursor(cr_default)
	timing_create_depth(0, 0, -9999, o_friendspanel)
}
