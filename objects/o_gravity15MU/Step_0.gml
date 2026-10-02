if (!timing_instance_step()) exit;
if global.pause = 1{ image_speed = 0 }
if global.pause = 0{ image_speed = 1 * (60 / TCC_SIM_HZ) }
if global.pause = 1 { exit }
y += randomfallspeed * (60 / TCC_SIM_HZ)
if change = 0 {
singo += sinchange * (60 / TCC_SIM_HZ)
if singo > singolimit { change = 1 }
} else {
singo -= sinchange * (60 / TCC_SIM_HZ)
if singo < -singolimit { change = 0 }	
}
x += sin(singo)

if y > room_height+32 { instance_destroy() }