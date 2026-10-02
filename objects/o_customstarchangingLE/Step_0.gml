if (!timing_instance_step()) exit;
/// @description Keys presses
if timing_keyboard_down(vk_right) {
global.LEStarRotation += 1 * (60 / global.maxfps)
}
if timing_keyboard_down(vk_left) {
global.LEStarRotation -= 1 * (60 / global.maxfps)
}

if global.LEStarRotation > 360 {
global.LEStarRotation = 0	
}
if global.LEStarRotation < 0 {
global.LEStarRotation = 360	
}

if timing_keyboard_down(vk_enter) ||  timing_keyboard_down(vk_escape) {
instance_destroy()
global.LEStarRotation = round(global.LEStarRotation)
}