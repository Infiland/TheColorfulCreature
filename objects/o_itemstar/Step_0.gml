image_alpha -= 0.05* (60 / global.maxfps);
speed += 0.25* (60 / global.maxfps)

if vib = 1 {
gamepad_set_vibration(0,image_alpha/4,image_alpha/4)
}
if image_alpha < 0 {
instance_destroy();	
gamepad_set_vibration(0,0,0)
}