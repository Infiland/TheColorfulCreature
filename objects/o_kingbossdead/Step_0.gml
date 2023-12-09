if global.pause = 1{ 
	image_speed = 0
	exit 
	}
image_speed = 1/3 * (60 / global.maxfps)
fall += 0.25 * (60 / global.maxfps)
randomize()
image_alpha -= 0.01 * (60 / global.maxfps)
y -= (5 - fall) * (60 / global.maxfps)
if image_alpha < 0 {
room_goto(r_theend)
}
x += gotheredead