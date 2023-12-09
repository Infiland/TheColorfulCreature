timer -= 1 * (60 / global.maxfps)
if timer < 0 {
image_alpha -= 0.08 * (60 / global.maxfps)
if image_alpha < 0 { instance_destroy() }
}

fall += 0.05 * (60 / global.maxfps)
x += dir
y -= (0.5 - fall) * (60 / global.maxfps)