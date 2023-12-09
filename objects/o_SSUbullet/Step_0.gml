if global.pause = 1 { 
	speed = 0
	exit }

speed = 10 * (60 / global.maxfps)
image_angle += 5 * (60 / global.maxfps)