image_alpha -= 0.003 * (60 / global.maxfps)
if image_alpha < 0 { instance_destroy() }