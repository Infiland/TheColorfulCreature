function horizontalcollision() {
	if (scr_slope_near_actor(hsp, 0, 3)) {
		var _slope = scr_slope_resolve_horizontal(hsp, vsp >= 0);
		hsp = _slope.dx;
		y += _slope.dy;
		return;
	}
	if (place_meeting(x+hsp,y,o_anyblock)) {	
	    while (!place_meeting(x+sign(hsp),y,o_anyblock)) 
	{
	x = x + sign(hsp);
	}
	hsp = 0;
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

function slopecollision_zero_gravity() {
    if (!scr_slope_near_actor(hspeed, vspeed, 1)) return;
    var _old_x = x;
    var _horizontal = scr_slope_resolve_horizontal(hspeed, false);
    x += _horizontal.dx;
    var _vertical = scr_slope_resolve_vertical(vspeed);
    if (_horizontal.blocked || _vertical.blocked) {
        // Built-in velocity will move the player after Step. On contact consume
        // only the swept, unobstructed part now, then stop that automatic move.
        y += _vertical.dy;
        speed = 0;
    } else {
        x = _old_x;
    }
}
