function loadhud() {
	var hx = 0
	var hy = 0
	if !is_struct(self) { hx = x; hy = y }

	if !instance_exists(o_time) { instance_create(hx,hy,o_time) }
	if !instance_exists(o_timecounter) { instance_create(hx,hy,o_timecounter) }
	if !instance_exists(o_ammocounter) { instance_create(hx,hy,o_ammocounter) }
	if !instance_exists(o_deathcounter) { instance_create(hx,hy,o_deathcounter) }
	if global.endless = 0 {
	if global.challenges = 0 {
	if global.workshop = 0 {
	if global.calendar = 0 {
	if global.dailylevel = 0 {
	if !instance_exists(o_coincounter) { instance_create(hx,hy,o_coincounter) }
	}}}}}
	if !instance_exists(o_fadecontroller) { instance_create(hx,hy,o_fadecontroller) }
	if !instance_exists(o_pausesystem) { instance_create(hx,hy,o_pausesystem) }
	if !instance_exists(o_musicdistortion) { instance_create(hx,hy,o_musicdistortion) }

	// Update Steam Rich Presence for current game state
	set_rich_presence()
}
