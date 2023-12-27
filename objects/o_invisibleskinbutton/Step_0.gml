if global.skin036 = 0 {
sprite_index = s_lockedskinbutton	
}
if global.skin036 = 1 {
sprite_index = s_invisibleskinbutton
if global.visiblethings = 1 { sprite_index = s_normalskinbutton }
}

if global.skinpage = page {
x = lerp(x,originalx,0.2 * (60 / global.maxfps))
y = lerp(y,originaly,0.2 * (60 / global.maxfps))
}
if global.skinpage < page {
x = lerp(x,1164,0.2 * (60 / global.maxfps))
y = lerp(y,416,0.2 * (60 / global.maxfps))	
}
if global.skinpage > page {
x = lerp(x,-140,0.2 * (60 / global.maxfps))
y = lerp(y,416,0.2 * (60 / global.maxfps))	
}