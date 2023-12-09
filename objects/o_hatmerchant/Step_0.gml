if os_type != os_android {
if interactcontrols = 0 {
key_interact = keyboard_check_pressed(ord(global.controlsinteract)) || (gamepad_button_check_pressed(4,gp_shoulderr)) //|| keyboard_check_pressed(ord("S"));
} else { key_interact = keyboard_check_pressed(global.controlsinteract) }
} else {
if instance_exists(o_buttoninteractandroid) {
key_interact = o_buttoninteractandroid.image_index = 1;
}
}

if instance_exists(o_player) {
if distance_to_object(o_player) < 70 {
if o_player.y - 10 <= ystart {
y = lerp(y,ystart - 10,0.12)
caninteract = 1
}
} else { y = lerp(y,ystart,0.12)
caninteract = 0
interacted = 0
if global.world5 = 0 {
textnumber = irandom_range(1,15)
} else { textnumber = irandom_range(1,16) }
instance_destroy(o_creditscounter)
instance_destroy(o_hatshopmenu)
	}

if distance_to_object(o_player) < 20 {
image_index = 0	
} else {
if o_player.x < x { image_index = 1 }
if o_player.x > x { image_index = 2 }
}

} else { y = lerp(y,ystart,0.12) }

if caninteract = 1 {
if key_interact {
	if !steam_get_achievement("HAT_MERCHANT") { steam_set_achievement("HAT_MERCHANT") }
	interacted = 1
	}
}

//Randomized Text
switch(textnumber) {
case(1): text = loc(211) break;
case(2): text = loc(212) break;
case(3): text = loc(213) break;
case(4): text = loc(214) break;
case(5): text = loc(215) break;
case(6): text = loc(216) break;
case(7): text = loc(217) break;
case(8): text = loc(218) break;
case(9): text = loc(219) break;
case(10): text = loc(220) break;
case(11): text = loc(221) break;
case(12): text = loc(222) break;
case(13): text = loc(223) break;
case(14): text = loc(224) break;
case(15): text = loc(225) break;
case(16): text = "Want discounts? Well, play hardmode for once in your life!" break;
}
