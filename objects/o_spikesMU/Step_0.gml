if global.pause = 1 { exit }
y += (randomfallspeed  * (60 / global.maxfps))

if y > room_height+32 { instance_destroy() }