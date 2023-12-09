if global.pause = 1 { speed = 0 
image_angle += 0
	}
if global.pause = 0 { speed = 5 * (60 / global.maxfps)
image_angle += 4 * (60 / global.maxfps)
}
if y > room_height+32 { instance_destroy() }
if x > room_width+32 { instance_destroy() }
if x < 0 { instance_destroy() }