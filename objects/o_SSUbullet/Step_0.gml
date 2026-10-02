if (!timing_instance_step()) exit;
if global.pause = 1 { 
	speed = 0
	exit }

speed = 10 * (60 / TCC_SIM_HZ)
image_angle += 5 * (60 / TCC_SIM_HZ)