if (!timing_instance_step()) exit;
if global.pause = 1 { exit }
y += 1 * (60 / TCC_SIM_HZ)
if timer < 0 {instance_destroy()}
timer -= 1 * (60 / TCC_SIM_HZ)
image_alpha -= 0.0666666666666667 * (60 / TCC_SIM_HZ)