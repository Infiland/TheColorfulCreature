if press = 1 { pressed = 1 press = 0 }
if instance_place(x+16,y+16,o_indicatorandroid) { image_index = 1 
	if pressed = 0 {
	press = 1 
	}
	} else { image_index = 0 pressed = 0 press = 0 }

/*if place_meeting(x,y,o_parentandroidbutton) {
x = xprevious
y = yprevious
}*/