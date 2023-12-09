if global.pause = 1 { exit }
if appear = 1 {
if image_alpha < 1 {
image_alpha += 0.025 * (60 / global.maxfps) 
}
}

if image_alpha < 0.01 {
image_index = 0
}

timer -= 1 * (60 / global.maxfps) 
if timer < 1 {
appear = 1
image_index = 0
}