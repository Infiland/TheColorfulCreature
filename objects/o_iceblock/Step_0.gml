if instance_exists(o_player) {
if distance_to_object(o_player) > 1300 {
exit
}}

if global.whiteblock > 0 {
if global.pause = 0 {
if !place_meeting(x,y+32,o_iceblock) {
timer -= 1 	
if timer = 0 {
instance_create(x+random_range(0,32),y+32,o_playertear)
timer = irandom_range(50,100)
}}}}

scr_renderblocks()