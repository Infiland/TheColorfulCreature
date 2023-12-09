randomize()
depth = 1
spikespeed = 1
change = 0
originalcooldown = 20
cooldown = originalcooldown
canmove = true
lockmove = false
dist = 4

if !place_meeting(x+32,y+32-dist,o_anyblock) || place_meeting(x,y+23-dist,o_anyblock) {
change = 1	
}
image_blend = c_yellow
image_speed = 0
alarm[0] = 1