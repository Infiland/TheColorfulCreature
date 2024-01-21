event_inherited()
if global.hat049 = 1 {
sprite_index = s_germanhaticon
} else { sprite_index = s_lockedhaticon }

if global.hatpage = page {
x = lerp(x,originalx,0.2 * (60 / global.maxfps))
y = lerp(y,originaly,0.2 * (60 / global.maxfps))
}
if global.hatpage < page {
x = lerp(x,1164,0.2 * (60 / global.maxfps))
y = lerp(y,416,0.2 * (60 / global.maxfps))	
}
if global.hatpage > page {
x = lerp(x,-140,0.2 * (60 / global.maxfps))
y = lerp(y,416,0.2 * (60 / global.maxfps))	
}