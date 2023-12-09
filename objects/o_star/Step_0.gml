if global.pause = 1{ speed = 0 }
if global.pause = 0{ previousspeed = speed 
randomize()
speed -= random_range(0.2 * (60 / global.maxfps),0.6 * (60 / global.maxfps))
image_angle += 2
}
if speed < (-9 * (60 / global.maxfps)) / zdepth {
speed = (-9 * (60 / global.maxfps)) / zdepth
distance -= speed
}

if distance > 1033 {
if instance_exists(o_player) {
if distance_to_object(o_player) < 512 {

} else { instance_destroy() }
} else { instance_destroy() }
}