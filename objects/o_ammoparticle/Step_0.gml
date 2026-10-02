if (!timing_instance_step()) exit;
image_alpha -= 0.0125* (60 / TCC_SIM_HZ)
image_xscale = 0.4
image_yscale = 0.4
y -= ((5 - fall) * global.delta) * (60 / TCC_SIM_HZ)
x += (bulletmovement * global.delta) * (60 / TCC_SIM_HZ)
image_angle += (rotationspeed * global.delta)* (60 / TCC_SIM_HZ)
fall += (0.25 * global.delta)* (60 / TCC_SIM_HZ)
if image_alpha < 0 { instance_destroy() }