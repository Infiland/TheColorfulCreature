function scr_animatedeyesMU(){
if vsp = 0 {eyesY = lerp(eyesY,0,0.2 * (60 / global.maxfps))}
if vsp < 0 {eyesY = lerp(eyesY,-4,0.2 * (60 / global.maxfps))}
if vsp > 0 {eyesY = lerp(eyesY,4,0.2 * (60 / global.maxfps))}
if hsp != 0 {
if playermove = 1 {
eyesX = lerp(eyesX,3,0.2 * (60 / global.maxfps))
}
if playermove = -1 {
eyesX = lerp(eyesX,-3,0.2 * (60 / global.maxfps))
}}
}