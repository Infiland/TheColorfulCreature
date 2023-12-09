if global.skin010 = 0 {
sprite_index = s_lockedskinbutton	
}
if global.skin010 = 1 {
sprite_index = s_coolskinbutton	
}
if global.skinschange = 0 and global.skinpage = 1 {
x = lerp(x,originalx,0.2 * (60 / global.maxfps))
y = lerp(y,originaly,0.2 * (60 / global.maxfps))
}
if global.skinschange = 0 and global.skinpage != 1 {
x = lerp(x,-140,0.2 * (60 / global.maxfps))
y = lerp(y,416,0.2 * (60 / global.maxfps))	
}
if global.skinschange = 1 {
x = lerp(x,480,0.2 * (60 / global.maxfps))
y = lerp(y,800,0.2 * (60 / global.maxfps))
}