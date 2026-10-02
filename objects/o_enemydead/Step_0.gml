if (!timing_instance_step()) exit;
fall += 0.5
tcc_randomize()
image_alpha -= 0.05 * (60 / TCC_SIM_HZ)
y -= 7 - fall
if image_alpha < 0 {
instance_destroy();
}
x = x + gotheredead
if image_index = 5 { image_speed = 0 }