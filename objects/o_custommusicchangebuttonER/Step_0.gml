if global.CESConfigure = 4 {
x = lerp(x,xstart,0.2 * (60 / global.maxfps))
} else {
x = lerp(x,-300,0.2 * (60 / global.maxfps))
}