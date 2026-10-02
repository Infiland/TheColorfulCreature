if (!timing_instance_step()) exit;
timer -= 1 * (60 / TCC_SIM_HZ)
if timer < 0 {
image_alpha -= 0.08 * (60 / TCC_SIM_HZ)
if image_alpha < 0 { instance_destroy() }
}

fall += 0.05 * (60 / TCC_SIM_HZ)
x += dir
y -= (0.5 - fall) * (60 / TCC_SIM_HZ)