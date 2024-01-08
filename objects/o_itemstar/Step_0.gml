image_alpha -= 0.05* (60 / global.maxfps);
speed += 0.25* (60 / global.maxfps)

if vib = 1 {
var vb = global.controllervibrationsettings
gamepad_set_vibration(0,(image_alpha/4)*vb,(image_alpha/4)*vb)
}
if image_alpha < 0 {
instance_destroy();	
gamepad_set_vibration(0,0,0)
}