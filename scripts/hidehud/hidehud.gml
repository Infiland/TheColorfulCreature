function hidehud() {
	instance_destroy(o_time)
	instance_destroy(o_timecounter)
	instance_destroy(o_ammocounter)
	instance_destroy(o_deathcounter)
	instance_destroy(o_coincounter)
	instance_destroy(o_fadecontroller)
	instance_destroy(o_pausesystem)
	instance_destroy(o_musicdistortion)
	instance_destroy(o_difficultycounter)
	instance_destroy(o_levelcounter)
}