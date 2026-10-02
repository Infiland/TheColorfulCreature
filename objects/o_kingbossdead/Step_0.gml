if (!timing_instance_step()) exit;
if global.pause = 1{ 
	image_speed = 0
	exit 
	}
image_speed = 1/3 * (60 / TCC_SIM_HZ)
fall += 0.25 * (60 / TCC_SIM_HZ)
tcc_randomize()
image_alpha -= 0.01 * (60 / TCC_SIM_HZ)
y -= (5 - fall) * (60 / TCC_SIM_HZ)
if image_alpha < 0 {
room_goto(r_theend)
}
x += gotheredead