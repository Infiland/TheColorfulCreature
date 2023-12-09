timer -= 1
if timer < 0 {
if global.CERMusicChange != 9999 {
global.CERMusicChange += 1
timer = timer2 * (global.maxfps / 60)
timer2 -= 0.4
}}