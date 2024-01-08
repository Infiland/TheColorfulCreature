image_alpha = lerp(image_alpha,0,0.08 * (60 / global.maxfps))
if instance_exists(o_door) {
x = lerp(x,o_door.x+12,0.1 * (60 / global.maxfps))
y = lerp(y,o_door.y+24,0.1 * (60 / global.maxfps))
}
if instance_exists(o_lockeddoor) {
x = lerp(x,o_lockeddoor.x+12,0.1 * (60 / global.maxfps))
y = lerp(y,o_lockeddoor.y+24,0.1 * (60 / global.maxfps))
}
if !instance_exists(o_door) and !instance_exists(o_lockeddoor) {
instance_destroy()
}

var vb = global.controllervibrationsettings
gamepad_set_vibration(0,(image_alpha/5)*vb,(image_alpha/5)*vb)
if image_alpha < 0.01 { instance_destroy() }