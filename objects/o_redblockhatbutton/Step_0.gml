if global.hat015 = 1 {
sprite_index = s_redblockhaticon
} else { sprite_index = s_lockedhaticon }

if global.hatpage = 1 {
x = lerp(x,originalx,0.2 * (60 / global.maxfps))
y = lerp(y,originaly,0.2 * (60 / global.maxfps))
}
if global.hatpage != 1 {
x = lerp(x,-140,0.2 * (60 / global.maxfps))
y = lerp(y,416,0.2 * (60 / global.maxfps))	
}