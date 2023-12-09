randomize()
depth = 1
y = round(y)
originaly = 0
spikespeed = 0.5
change = 0
originalcooldown = 20
cooldown = originalcooldown
originaly = clamp(originaly, 0, 32);
image_blend = c_lime
image_speed = 0
alarm[0] = 1

if !place_meeting(x+32,y+32,o_anyblock) and !place_meeting(x-32,y+32,o_anyblock) and place_meeting(x,y+32,o_anyblock){
mask_index = s_spikeblockhitbox
}