image_index = global.infinitelivessettings
if global.choosesettings != 4 { x = lerp(x,-256,0.2 * (60 / global.maxfps)) }
if global.choosesettings = 4 { x = lerp(x,32,0.2 * (60 / global.maxfps)) }

if global.cheats = 0 {
image_alpha = 0.5
} else { image_alpha = 1 }