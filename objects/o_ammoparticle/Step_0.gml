image_alpha -= 0.0125* (60 / global.maxfps)
image_xscale = 0.4
image_yscale = 0.4
y -= ((5 - fall) * global.delta) * (60 / global.maxfps)
x += (bulletmovement * global.delta) * (60 / global.maxfps)
image_angle += (rotationspeed * global.delta)* (60 / global.maxfps)
fall += (0.25 * global.delta)* (60 / global.maxfps)
if image_alpha < 0 { instance_destroy() }