if (!timing_instance_step()) exit;
target = instance_nearest(x, y, o_playerMU);
if global.pause = 1 { 
	speed = 0
	exit
	}
if global.pause = 0 {
speed = speedold	
}
if !instance_exists(target) {
speedold = speed
}

if place_meeting(x,y,o_water) { inwater = 2 } else { inwater = 1 }
if instance_exists(o_playerMU) {
tcc_randomize()
if inwater = 1 { randomness += 0.25 * (60 / TCC_SIM_HZ) } else { randomness += 0.35 * (60 / TCC_SIM_HZ) }
if randomness > 95 { image_blend = c_red }
if randomness > 100 { instance_destroy() }
var pointdir = point_direction(x,y,target.x+16,target.y+16)
realpointdir = lerp(realpointdir,pointdir,0.15)
image_angle += sin(degtorad(realpointdir - image_angle + random_range(randomness,-randomness))) * speed
direction = image_angle
speed += 0.05 * (60 / TCC_SIM_HZ)
speedold = speed
if speed > (3.5 / inwater) * (60 / TCC_SIM_HZ) {speed = (3.5/inwater) * (60 / TCC_SIM_HZ)}
if speedold > (3.5/inwater) * (60 / TCC_SIM_HZ) {speedold = (3.5/inwater) * (60 / TCC_SIM_HZ)}
}