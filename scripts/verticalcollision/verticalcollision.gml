function verticalcollision() {
	if (place_meeting(x,y+vsp,o_anyblock)) {
	    while (!place_meeting(x,y+sign(vsp),o_anyblock)) 
	    {
	        y = y + sign(vsp);
	    }
	    vsp = 0;
	}
	if (place_meeting(x+hsp,y,o_movingplatforms)) {
	    while (!place_meeting(x+sign(hsp),y,o_movingplatforms)) 
	    {
	        x = x + sign(hsp);
	    }
	    hsp = 0;
	}
	if (place_meeting(x,y+vsp,o_shooter)) {
	    while (!place_meeting(x,y+sign(vsp),o_shooter)) 
	    {
	        y = y + sign(vsp);
	    }
	    vsp = 0;
	}
	if (place_meeting(x,y+vsp,o_shooterright)) {
	    while (!place_meeting(x,y+sign(vsp),o_shooterright))
	    {
	        y = y + sign(vsp);
	    }
	    vsp = 0;
	}
	if (place_meeting(x,y+vsp,o_rocketlauncher)) {
	    while (!place_meeting(x,y+sign(vsp),o_rocketlauncher)) 
	    {
	        y = y + sign(vsp);
	    }
	    vsp = 0;
	}
	if (place_meeting(x,y+vsp,o_rocketlauncherright)) {
	    while (!place_meeting(x,y+sign(vsp),o_rocketlauncherright))
	    {
	        y = y + sign(vsp);
	    }
	    vsp = 0;
	}
	if vsp > 0 {
	if (place_meeting(x,y+vsp,o_onewayupblock)) {
	    while (!place_meeting(x,y+sign(vsp),o_onewayupblock))
	    {
	        y = y + sign(vsp);
	    }
	    vsp = 0;
	}}
	if vsp < 0 {
	if (place_meeting(x,y+vsp,o_onewaydownblock)) {
	    while (!place_meeting(x,y+sign(vsp),o_onewaydownblock))
	    {
	        y = y + sign(vsp);
	    }
	    vsp = 0;
	}}
	if instance_exists(o_playerMU) {
	if (place_meeting(x,y+vsp,o_playerMU)) {
	    while (!place_meeting(x,y+sign(vsp),o_playerMU)) 
	    {
	        y = y + sign(vsp);
	    }
	    vsp = 0;
	}}


}
