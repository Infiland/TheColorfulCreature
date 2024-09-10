image_alpha = 0
maxalpha = random_range(0.2,0.5)
timer = random_range(300,480)
if place_meeting(x,y,o_anyblock) || place_meeting(x,y,o_deathblock) or place_meeting(x,y,o_onewayupblock) or place_meeting(x,y,o_onewaydownblock) or place_meeting(x,y,o_onewayrightblock) {
instance_destroy()	
}
direction = random_range(0,360)
speed = random_range(0.1 * (60 / global.maxfps),1*(60 / global.maxfps))