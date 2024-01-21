event_inherited()
if global.item003 = 1 {
sprite_index = s_shielditembutton
} else { sprite_index = s_lockeditemicon }

if global.itempage = 1 {
x = lerp(x,originalx,0.2 * (60 / global.maxfps))
y = lerp(y,originaly,0.2 * (60 / global.maxfps))
} else {
x = lerp(x,-140,0.2 * (60 / global.maxfps))
y = lerp(y,416,0.2 * (60 / global.maxfps))	
}