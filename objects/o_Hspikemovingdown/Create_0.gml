randomize()
depth = 1
spikespeed = 1
change = 0
originalcooldown = 20
cooldown = originalcooldown
canmove = true
lockmove = false
dist = 28

if !place_meeting(x+dist,y-32,o_anyblock) || place_meeting(x-23+dist,y,o_anyblock) {
change = 1	
}
image_blend = c_yellow
image_speed = 0
alarm[0] = 1