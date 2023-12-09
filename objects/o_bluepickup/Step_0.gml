size += 0.025 * (60 / global.maxfps)
image_xscale = size;
image_yscale = size;
image_alpha -= 0.05 * (60 / global.maxfps)
gamepad_set_vibration(0,image_alpha/5,image_alpha/5)
if image_alpha < 0 { instance_destroy()
	gamepad_set_vibration(0,0,0)
	}