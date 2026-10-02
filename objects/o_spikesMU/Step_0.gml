if (!timing_instance_step()) exit;
if global.pause = 1 { exit }
y += (randomfallspeed  * (60 / TCC_SIM_HZ))

if y > room_height+32 { instance_destroy() }