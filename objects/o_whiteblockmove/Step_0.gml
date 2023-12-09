if global.pause = 1 { exit }
mask_index = s_redblockplatform
hsp = (movespeed * (60 / global.maxfps)) * dir

//Collision
if (place_meeting(x+hsp,y,o_anyblock)) {
		while(!place_meeting(x+sign(hsp),y,o_anyblock)) {
        x += sign(hsp)	
		}
		hsp = 0;
		dir *= -1
}
if (place_meeting(x+hsp,y,o_deathblock)) {
		while(!place_meeting(x+sign(hsp),y,o_deathblock)) {
        x += sign(hsp)	
		}
		hsp = 0;
		dir *= -1
}
if (place_meeting(x+hsp,y,o_redblockmove)) {
		while(!place_meeting(x+sign(hsp),y,o_redblockmove)) {
        x += sign(hsp)	
		}
		hsp = 0;
		dir *= -1
}
if (place_meeting(x+hsp,y,o_yellowblockmove)) {
		while(!place_meeting(x+sign(hsp),y,o_yellowblockmove)) {
        x += sign(hsp)	
		}
		hsp = 0;
		dir *= -1
}
if (place_meeting(x+hsp,y,o_greenblockmove)) {
		while(!place_meeting(x+sign(hsp),y,o_greenblockmove)) {
        x += sign(hsp)	
		}
		hsp = 0;
		dir *= -1
}
if (place_meeting(x+hsp,y,o_blueblockmove)) {
		while(!place_meeting(x+sign(hsp),y,o_blueblockmove)) {
        x += sign(hsp)	
		}
		hsp = 0;
		dir *= -1
}
if (place_meeting(x+hsp,y,o_whiteblockmove)) {
		while(!place_meeting(x+sign(hsp),y,o_whiteblockmove)) {
        x += sign(hsp)	
		}
		hsp = 0;
		dir *= -1
}
if global.noclip = 0 {
if (place_meeting(x+hsp,y,o_player)) {
		while(!place_meeting(x+sign(hsp),y,o_player)) {
        x += sign(hsp)	
		}
		hsp = 0;
		dir *= -1
}}
if instance_exists(o_playerMU) {
if (place_meeting(x+hsp,y,o_playerMU)) {
		while(!place_meeting(x+sign(hsp),y,o_playerMU)) {
        x += sign(hsp)	
		}
		hsp = 0;
		dir *= -1
}}
if (place_meeting(x+hsp,y,o_enemyplayer)) {
		while(!place_meeting(x+sign(hsp),y,o_enemyplayer)) {
        x += sign(hsp)	
		}
		hsp = 0;
		dir *= -1
}
if dir = 1 {
if (place_meeting(x+hsp,y,o_onewayleftblock)) {
		while(!place_meeting(x+sign(hsp),y,o_onewayleftblock)) {
        x += sign(hsp)	
		}
		hsp = 0;
		dir *= -1
}}
if dir = -1 {
if (place_meeting(x+hsp,y,o_onewayrightblock)) {
		while(!place_meeting(x+sign(hsp),y,o_onewayrightblock)) {
        x += sign(hsp)	
		}
		hsp = 0;
		dir *= -1
}}
x += hsp

if instance_exists(o_player) {
if distance_to_object(o_player) > 1300 {
exit
}}
if global.visual3dsettings = 1 {
hdepth = (obj_to_follow.x-x)/factor;
vdepth = (obj_to_follow.y-y)/factor;

if (hdepth > max_depth/2) {

    hdepth=max_depth/2;

}

if (hdepth < -max_depth/2) {

    hdepth=-max_depth/2;

}

if (vdepth > max_depth/2) {

    vdepth=max_depth/2;

}

if (vdepth < -max_depth/2) {

    vdepth=-max_depth/2;

}
}

if hidesprites = true {
if distance_to_object(o_player)	< 1100 {
hidesprites = false 	
}}

scr_activateobjects()