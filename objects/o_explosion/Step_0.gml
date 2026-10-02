if (!timing_instance_step()) exit;
if global.pause = 0 {
	image_speed = 1 * (60 / TCC_SIM_HZ)
} else {
	image_speed = 0
}