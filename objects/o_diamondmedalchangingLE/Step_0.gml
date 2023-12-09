/// @description Keys presses
if keyboard_check(vk_shift) {
if keyboard_check(vk_right) {
global.LEDiamondMedalTime += 0.01 * (60 / global.maxfps)
}
if keyboard_check(vk_left) {
global.LEDiamondMedalTime -= 0.01 * (60 / global.maxfps)
}} else {
if keyboard_check(vk_right) {
global.LEDiamondMedalTime += 0.1 * (60 / global.maxfps)
}
if keyboard_check(vk_left) {
global.LEDiamondMedalTime -= 0.1 * (60 / global.maxfps)
}
}

if global.LEDiamondMedalTime < 0 {
global.LEDiamondMedalTime = 0	
}
if global.LEDiamondMedalTime > 999 {
global.LEDiamondMedalTime = 999
}

if keyboard_check(vk_enter) || keyboard_check_released(vk_escape) {
instance_destroy()
instance_destroy(o_settimertodiamondtimeLE) 
}