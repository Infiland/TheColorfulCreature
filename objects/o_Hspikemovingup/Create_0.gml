randomize()
depth = 1
spikespeed = 1
change = 0
originalcooldown = 20
cooldown = originalcooldown
canmove = true
lockmove = false
dist = 28

if !place_meeting(x-dist,y+32,o_anyblock) || place_meeting(x-dist,y,o_anyblock) {
change = 1	
}
image_blend = c_yellow
image_speed = 0
alarm[0] = 1

goldenspikechance = irandom_range(0,1000)
if goldenspikechance = 420 {
sprite_index = s_goldenspike	
}

if !place_meeting(x+32,y+32,o_anyblock) and !place_meeting(x-32,y+32,o_anyblock) and place_meeting(x,y+32,o_anyblock){
mask_index = s_spikeblockhitbox
}
if mask_index = s_spikeblockhitbox {
lockmove = true
}