if lvl != 0 {
if global.CESConfigure = 2 {
x = lerp(x,xstart,0.2 * (60 / global.maxfps))
} else {
x = lerp(x,-300,0.2 * (60 / global.maxfps))
}}

if mus != 0 {
if global.CESConfigure = 3 {
x = lerp(x,xstart,0.2 * (60 / global.maxfps))
} else {
x = lerp(x,-300,0.2 * (60 / global.maxfps))
}}

y = lerp(y,ystart + global.CERyscroll,0.1 * (60 / global.maxfps))