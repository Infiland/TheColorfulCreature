function scr_animatedeyes(){
if vsp = 0 {eyesY = lerp(eyesY,0,0.2 * (60 / global.maxfps))}
if vsp < 0 {eyesY = lerp(eyesY,-4,0.2 * (60 / global.maxfps))}
if vsp > 0 {eyesY = lerp(eyesY,4,0.2 * (60 / global.maxfps))}

if hsp = 0 { eyesX = lerp(eyesX,0,0.2 * (60 / global.maxfps)) }
if hsp != 0 {
if global.playermove = 1 {
eyesX = lerp(eyesX,4,0.2 * (60 / global.maxfps))
}
if global.playermove = -1 {
eyesX = lerp(eyesX,-4,0.2 * (60 / global.maxfps))
}}
}