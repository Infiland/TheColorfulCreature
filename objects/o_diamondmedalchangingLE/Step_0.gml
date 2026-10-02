if (!timing_instance_step()) exit;
/// @description Keys presses
if timing_keyboard_down(vk_shift) {
if timing_keyboard_down(vk_right) {
global.LEDiamondMedalTime += 0.01 * (60 / global.maxfps)
}
if timing_keyboard_down(vk_left) {
global.LEDiamondMedalTime -= 0.01 * (60 / global.maxfps)
}} else {
if timing_keyboard_down(vk_right) {
global.LEDiamondMedalTime += 0.1 * (60 / global.maxfps)
}
if timing_keyboard_down(vk_left) {
global.LEDiamondMedalTime -= 0.1 * (60 / global.maxfps)
}
}

if global.LEDiamondMedalTime < 0 {
global.LEDiamondMedalTime = 0	
}
if global.LEDiamondMedalTime > 999 {
global.LEDiamondMedalTime = 999
}

if timing_keyboard_down(vk_enter) || timing_keyboard_released(vk_escape) {
instance_destroy()
instance_destroy(o_settimertodiamondtimeLE) 
}