function loadhud() {
	if !instance_exists(o_time) { instance_create(x,y,o_time) }
	if !instance_exists(o_timecounter) { instance_create(x,y,o_timecounter) }
	if !instance_exists(o_ammocounter) { instance_create(x,y,o_ammocounter) }
	if !instance_exists(o_deathcounter) { instance_create(x,y,o_deathcounter) }
	if global.endless = 0 {
	if global.challenges = 0 {
	if global.workshop = 0 {
	if global.calendar = 0 {
	if global.dailylevel = 0 {
	if !instance_exists(o_coincounter) { instance_create(x,y,o_coincounter) }
	}}}}}
	if !instance_exists(o_fadecontroller) { instance_create(x,y,o_fadecontroller) }
	if !instance_exists(o_pausesystem) { instance_create(x,y,o_pausesystem) }
	if !instance_exists(o_musicdistortion) { instance_create(x,y,o_musicdistortion) }


}
