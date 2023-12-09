function loadhudMU() {
	if !instance_exists(o_fadecontroller) { instance_create(x,y,o_fadecontroller) }
	if !instance_exists(o_pausesystem) { instance_create(x,y,o_pausesystem) }
}
