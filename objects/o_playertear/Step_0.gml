if global.pause = 1 { exit }
y += 1 * (60 / global.maxfps)
if timer < 0 {instance_destroy()}
timer -= 1 * (60 / global.maxfps)
image_alpha -= 0.0666666666666667 * (60 / global.maxfps)