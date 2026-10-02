if (!timing_instance_step()) exit;
timer -= 1 * (60 / TCC_SIM_HZ)
if timer > 0 {
if image_alpha < maxalpha
image_alpha += 0.01 * (60 / TCC_SIM_HZ)
}
if timer < 0 {
image_alpha -= 0.01 * (60 / TCC_SIM_HZ)
if image_alpha < 0 { instance_destroy() }
}