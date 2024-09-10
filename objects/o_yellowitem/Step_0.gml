if global.pause = 1 { image_speed = 0 } else { image_speed = 1 }
if room = r_leveleditor {
	if global.LES = 6 || 7 || 8 || 9 || 10 || 29 || 30 || 31 || 32 || 33 { //Wtf
		if place_meeting(x,y,o_redblock) || place_meeting(x,y,o_yellowblock) || place_meeting(x,y,o_greenblock) || place_meeting(x,y,o_blueblock) || place_meeting(x,y,o_whiteblock) || place_meeting(x,y,o_redpassblock) || place_meeting(x,y,o_yellowpassblock) || place_meeting(x,y,o_greenpassblock) || place_meeting(x,y,o_bluepassblock) {
			instance_destroy()	
		}
	}
}