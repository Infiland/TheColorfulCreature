scr_custombutton()

if global.CESConfigure = 3 {
x = lerp(x,xstart,0.1 * (60 / global.maxfps))
} else { x = lerp(x,newx,0.1 * (60 / global.maxfps)) }