function horizontalcollision() {
	
	if !place_meeting(x+hsp,y,o_redblockslope) {
	if (place_meeting(x+hsp,y,o_anyblock)) {	
	    while (!place_meeting(x+sign(hsp),y,o_anyblock)) 
	{
	x = x + sign(hsp);
	}
	hsp = 0;
	}} else {
	move_and_collide(0,0,o_anyblock,20)	
	}
	if (place_meeting(x+hsp,y,o_movingplatforms)) {
	    while (!place_meeting(x+sign(hsp),y,o_movingplatforms)) 
	    {
	        x = x + sign(hsp);
	    }
	    hsp = 0;
	}
	if hsp < 0 {
	if (place_meeting(x+hsp,y,o_onewayrightblock)) {
	    while (!place_meeting(x+sign(hsp),y,o_onewayrightblock))
	    {
	        x = x + sign(hsp);
	    }
	    hsp = 0;
	}}
	if hsp > 0 {
	if (place_meeting(x+hsp,y,o_onewayleftblock)) {
	    while (!place_meeting(x+sign(hsp),y,o_onewayleftblock))
	    {
	        x = x + sign(hsp);
	    }
	    hsp = 0;
	}}
	if instance_exists(o_playerMU) {
	if (place_meeting(x+hsp,y,o_playerMU)) {
	    while (!place_meeting(x+sign(hsp),y,o_playerMU))
	    {
	        x = x + sign(hsp);
	    }
	    hsp = 0;
	}}


}
