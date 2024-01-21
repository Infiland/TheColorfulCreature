event_inherited()
if global.hat012 = 1 {
sprite_index = s_grayhaticon
} else { sprite_index = s_lockedhaticon }

if global.hatpage = 1 {
x = lerp(x,originalx,0.2 * (60 / global.maxfps))
y = lerp(y,originaly,0.2 * (60 / global.maxfps))
}else {
x = lerp(x,-140,0.2 * (60 / global.maxfps))
y = lerp(y,416,0.2 * (60 / global.maxfps))	
}