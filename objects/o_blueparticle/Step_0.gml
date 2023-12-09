timer -= 1 * (60 / global.maxfps)
if timer > 0 {
if image_alpha < maxalpha
image_alpha += 0.01 * (60 / global.maxfps)
}
if timer < 0 {
image_alpha -= 0.01 * (60 / global.maxfps)
if image_alpha < 0 { instance_destroy() }
}