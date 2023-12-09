if global.skin048 = 0 {sprite_index = s_lockedskinbutton}
else { sprite_index = s_burningskinbutton }

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