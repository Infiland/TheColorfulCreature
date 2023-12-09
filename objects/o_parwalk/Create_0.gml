if instance_number(o_parwalk) > 50 {instance_destroy()	}

image_alpha = random_range(0.5,1)
depth = 10;
timer = irandom_range(1,12)
dir = 0
jumped = 0

col = -1
if place_meeting(x,y+1,o_redblock) || place_meeting(x,y+1,o_redblockmove) {col = 0} //Red
if place_meeting(x,y+1,o_yellowblock) || place_meeting(x,y+1,o_yellowblockmove) {col = 1} //Yellow
if place_meeting(x,y+1,o_greenblock) || place_meeting(x,y+1,o_greenblockmove) {col = 2} //Green
if place_meeting(x,y+1,o_blueblock) || place_meeting(x,y+1,o_blueblockmove) {col = 3} //Blue
if place_meeting(x,y+1,o_whiteblock) || place_meeting(x,y+1,o_whiteblockmove) {col = 4} //White

switch(col) {
default: instance_destroy()
case(0): sprite_index = s_redparticle break;
case(1): sprite_index = s_yellowparticle break;
case(2): sprite_index = s_greenparticle break;
case(3): sprite_index = s_blueparticle break;
case(4): sprite_index = s_whiteparticle break;
}
//direction = random_range(0,360)
//speed = random_range(0.1 * (60 / global.maxfps),1*(60 / global.maxfps))
alarm[0] = 1