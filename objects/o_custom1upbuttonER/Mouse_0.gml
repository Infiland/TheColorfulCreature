timer -= 1
if timer < 0 {
if global.CER1upChange != 9999 {
global.CER1upChange += 1
timer = timer2 * (global.maxfps / 60)
timer2 -= 0.4
}}