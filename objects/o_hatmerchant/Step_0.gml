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
case(1): text = loc("ALRIGHT_FRIEND_CHOOSE") break;
case(2): text = loc("THESE_WILL_LOOK_GOOD_ON_YOU") break;
case(3): text = loc("ALRIGHT_TAKE_A_LOOK") break;
case(4): text = loc("BUY_SOMETHING_WILL_YA") break;
case(5): text = loc("WE_HAVE_A_VARIETY_OF_HATS") break;
case(6): text = loc("YOU_HAVE_CREDITS_TO_USE_I_HAVE_HATS_TO_SELL") break;
case(7): text = loc("YOU_LOOK_RICH_I_LL_GIVE_YOU_HATS_IN_RETURN") break;
case(8): text = loc("SELLING_HATS_ONLY_50_CREDITS_AND_ABOVE") break;
case(9): text = loc("YOU_CAN_GET_HATS_ONLY_FROM_ME_IN_THIS_UNIVERSE") break;
case(10): text = loc("GET_SOMETHING_TO_WEAR_WILL_YA") break;
case(11): text = loc("TANGO_S_THE_NAME_AND_HAT_SELLING_S_MY_GAME") break;
case(12): text = loc("I_PERSONALLY_LIKE_MY_TOPHAT") break;
case(13): text = loc("I_DON_T_NEED_YOUR_COINS_I_NEED_CREDITS") break;
case(14): text = loc("IT_S_YOURS_MY_FRIEND_AS_LONG_AS_YOU_HAVE_ENOUGH_CREDITS") break;
case(15): text = loc("I_VE_HEARD_THERE_S_FAKE_BLOCKS_ALL_OVER_LEVELS_BUT_I_CAN_T_R") break;
case(16): text = "Want discounts? Well, play hardmode for once in your life!" break;
}
