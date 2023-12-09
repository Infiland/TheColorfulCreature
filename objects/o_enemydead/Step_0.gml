fall += 0.5
randomize()
image_alpha -= 0.05 * (60 / global.maxfps)
y -= 7 - fall
if image_alpha < 0 {
instance_destroy();
}
x = x + gotheredead
if image_index = 5 { image_speed = 0 }