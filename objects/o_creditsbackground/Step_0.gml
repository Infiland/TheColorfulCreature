x = lerp(x,mouse_x,0.004)
y = lerp(y,mouse_y,0.002)
if y > 540 { y = 540 }
if y < 228 { y = 228 }
if x > 960 { x = 960 }
if x < 64 { x = 64 }
image_alpha = lerp(image_alpha,1,0.02 * (60 / global.maxfps))