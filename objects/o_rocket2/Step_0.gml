if room = r_leveleditor {
	if global.LEMode = 1 {
	instance_destroy()	
	}
}
if global.pause = 1 { 
	speed = 0
	exit
	}
if global.pause = 0 {
speed = speedold	
}
if !instance_exists(o_player) {
speedold = speed
}
if place_meeting(x,y,o_water) { inwater = 2 } else { inwater = 1 }
if instance_exists(o_player) {
randomize()
if inwater = 1 { randomness += 0.25* (60 / global.maxfps) } else { randomness += 0.35* (60 / global.maxfps) }
if randomness > 95 { image_blend = c_red }
if randomness > 100 { instance_destroy() }
var pointdir = point_direction(x,y,o_player.x+16,o_player.y+16)
realpointdir = lerp(realpointdir,pointdir,0.15)
image_angle += sin(degtorad(realpointdir - image_angle + random_range(randomness,-randomness))) * speed
direction = image_angle
speed += 0.1 * (60 / global.maxfps)
speedold = speed
if speed > (4/inwater)* (60 / global.maxfps) {speed = (4/inwater)* (60 / global.maxfps)}
if speedold > (4/inwater)* (60 / global.maxfps) {speedold = (4/inwater)* (60 / global.maxfps)}
}
if place_meeting(x,y,o_redblock) { instance_destroy() }
if place_meeting(x,y,o_yellowblock) { instance_destroy() }
if place_meeting(x,y,o_greenblock) { instance_destroy() }
if place_meeting(x,y,o_blueblock) { instance_destroy() }
if place_meeting(x,y,o_whiteblock) { instance_destroy() }
if place_meeting(x,y,o_redblockmove) { instance_destroy() }
if place_meeting(x,y,o_yellowblockmove) { instance_destroy() }
if place_meeting(x,y,o_greenblockmove) { instance_destroy() }
if place_meeting(x,y,o_blueblockmove) { instance_destroy() }
if place_meeting(x,y,o_whiteblockmove) { instance_destroy() }
if place_meeting(x,y,o_iceblock) { instance_destroy() }
if place_meeting(x,y,o_deathblock) { instance_destroy() }
if randomness > 10 {
if place_meeting(x,y,o_rocketlauncher) { instance_destroy() }
if place_meeting(x,y,o_rocketlauncherright) { instance_destroy() }
if place_meeting(x,y,o_shooterright) { instance_destroy() }
if place_meeting(x,y,o_shooter) { instance_destroy() }
}

if place_meeting(x,y,o_onewayleftblock) {
if direction > -90 {
if direction < 90 {
instance_destroy()
}}}
if place_meeting(x,y,o_onewayrightblock) {
if direction < -270 or direction > 90 {
instance_destroy()
}}

if instance_exists(o_lockedblock) {
if place_meeting(x,y,o_lockedblock) {
if o_lockedblock.sprite_index = s_lockedblock {
instance_destroy()
}}}
if instance_exists(o_unlockedblock) {
if place_meeting(x,y,o_unlockedblock) {
if o_unlockedblock.sprite_index = s_lockedblock {
instance_destroy()
}}}

if room = r_leveleditor {
if !instance_exists(o_player) {
instance_destroy()
}
}

scr_activateobjects()