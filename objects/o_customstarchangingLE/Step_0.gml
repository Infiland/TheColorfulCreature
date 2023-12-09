/// @description Keys presses
if keyboard_check(vk_right) {
global.LEStarRotation += 1 * (60 / global.maxfps)
}
if keyboard_check(vk_left) {
global.LEStarRotation -= 1 * (60 / global.maxfps)
}

if global.LEStarRotation > 360 {
global.LEStarRotation = 0	
}
if global.LEStarRotation < 0 {
global.LEStarRotation = 360	
}

if keyboard_check(vk_enter) ||  keyboard_check(vk_escape) {
instance_destroy()
global.LEStarRotation = round(global.LEStarRotation)
}