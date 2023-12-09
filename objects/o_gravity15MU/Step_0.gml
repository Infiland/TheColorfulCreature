if global.pause = 1{ image_speed = 0 }
if global.pause = 0{ image_speed = 1 * (60 / global.maxfps) }
if global.pause = 1 { exit }
y += randomfallspeed * (60 / global.maxfps)
if change = 0 {
singo += sinchange * (60 / global.maxfps)
if singo > singolimit { change = 1 }
} else {
singo -= sinchange * (60 / global.maxfps)
if singo < -singolimit { change = 0 }	
}
x += sin(singo)

if y > room_height+32 { instance_destroy() }