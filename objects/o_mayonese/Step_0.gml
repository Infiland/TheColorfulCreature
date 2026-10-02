if (!timing_instance_step()) exit;
if global.pause = 1 { speed = 0 
image_angle += 0
	}
if global.pause = 0 { speed = 5 * (60 / TCC_SIM_HZ)
image_angle += 4 * (60 / TCC_SIM_HZ)
if global.easy = 1 {
	speed = -1
}}