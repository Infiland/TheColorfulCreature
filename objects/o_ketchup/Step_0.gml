if global.pause = 1 { speed = 0 
image_angle += 0
	}
if global.pause = 0 { speed = 5 * (60 / global.maxfps) 
image_angle += 4 * (60 / global.maxfps) 
if global.easy = 1 {
	speed = -1 * (60 / global.maxfps) 
}}