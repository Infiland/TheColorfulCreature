//Hat Shop
scr_playercontrolsconfig()

RLselectedhat = selectedhat * -1

if os_type != os_android {
if interactcontrols = 0 {
key_interact = keyboard_check_pressed(ord(global.controlsinteract))
} else { key_interact = keyboard_check_pressed(global.controlsinteract) }

}else {
key_interact = o_buttoninteractandroid.image_index = 1;
key_left = o_buttonleftandroid.image_index = 1;
key_right = o_buttonrightandroid.image_index = 1;
}

if keyboard_check_pressed(vk_enter) || key_interact {
switch(RLselectedhat) {
//Exit
case(0): instance_destroy() break;	


//Graduation Hat
case(1): makehatshop(global.hat001,floor(75 * global.hatmerchantdiscount),1) break;
//Cone Hat
case(2): makehatshop(global.hat002,floor(75 * global.hatmerchantdiscount),2) break;
//Party Hat
case(3): makehatshop(global.hat003,floor(112 * global.hatmerchantdiscount),3) break;
//Paper Hat
case(4): makehatshop(global.hat004,floor(75 * global.hatmerchantdiscount),4) break;
//Top Hat
case(5): makehatshop(global.hat005,floor(300 * global.hatmerchantdiscount),5) break;
//Golden Top Hat
case(6): makehatshop(global.hat006,floor(2250 * global.hatmerchantdiscount),6) break;
//Reddie Top Hat
case(7): makehatshop(global.hat007,floor(225 * global.hatmerchantdiscount),7)break;
//Christmas Hat
case(8): makehatshop(global.hat008,floor(112 * global.hatmerchantdiscount),8) break;
//Witch Hat
case(9): makehatshop(global.hat009,floor(112 * global.hatmerchantdiscount),9) break;
//Pumpkin Hat
case(10): makehatshop(global.hat010,floor(112 * global.hatmerchantdiscount),10)break;
//Brown Hat
case(11): makehatshop(global.hat011,floor(75 * global.hatmerchantdiscount),11) break;
//Gray Hat
case(12): makehatshop(global.hat012,floor(75 * global.hatmerchantdiscount),12) break;
//White Hat
case(13): makehatshop(global.hat013,floor(75 * global.hatmerchantdiscount),13) break;
//Sun Hat
case(14): makehatshop(global.hat014,floor(75 * global.hatmerchantdiscount),14) break;
//Red Block Hat
case(15): makehatshop(global.hat015,floor(75 * global.hatmerchantdiscount),15) break;
//Yellow Block Hat
case(16): makehatshop(global.hat016,floor(75 * global.hatmerchantdiscount),16) break;
//Green Block Hat
case(17): makehatshop(global.hat017,floor(75 * global.hatmerchantdiscount),17) break;
//Blue Block Hat
case(18): makehatshop(global.hat018,floor(75 * global.hatmerchantdiscount),18) break;
//White Block Hat
case(19): makehatshop(global.hat019,floor(75 * global.hatmerchantdiscount),19) break;
//Spike Hat
case(20): makehatshop(global.hat020,floor(75 * global.hatmerchantdiscount),20) break;
//Invisible Spike Hat
case(21): makehatshop(global.hat021,floor(112 * global.hatmerchantdiscount),21) break;
//Vertical Moving Spike Hat
case(22): makehatshop(global.hat022,floor(112 * global.hatmerchantdiscount),22) break;
//Horizontal Moving Spike Hat
case(23): makehatshop(global.hat023,floor(112 * global.hatmerchantdiscount),23) break;
//Hexagon Hat Icon
case(24): makehatshop(global.hat024,floor(180 * global.hatmerchantdiscount),24) break;
//Bread Hat Icon
case(25): makehatshop(global.hat025,floor(187 * global.hatmerchantdiscount),25) break;
//Soldier Hat Icon
case(26): makehatshop(global.hat026,floor(112 * global.hatmerchantdiscount),26) break;
//Samurai Hat Icon
case(27): makehatshop(global.hat027,floor(75 * global.hatmerchantdiscount),27) break;
//Red Beanie Hat Icon
case(28): makehatshop(global.hat028,floor(112 * global.hatmerchantdiscount),28) break;
//Yellow Beanie Hat Icon
case(29): makehatshop(global.hat029,floor(112 * global.hatmerchantdiscount),29) break;
//Green Beanie Hat Icon
case(30): makehatshop(global.hat030,floor(112 * global.hatmerchantdiscount),30) break;
//Blue Beanie Hat Icon
case(31): makehatshop(global.hat031,floor(112 * global.hatmerchantdiscount),31) break;
//White Beanie Hat Icon
case(32): makehatshop(global.hat032,floor(112 * global.hatmerchantdiscount),32) break;
//Pirate Hat Icon
case(33): makehatshop(global.hat033,floor(187 * global.hatmerchantdiscount),33) break;
//Pink Bowtie Hat Icon
case(34): makehatshop(global.hat034,floor(75 * global.hatmerchantdiscount),34) break;
//King Hat Icon
case(35): makehatshop(global.hat035,floor(749 * global.hatmerchantdiscount),35) break;
//Hair
case(36): makehatshop(global.hat036,floor(150 * global.hatmerchantdiscount),36) break;
//Comrade
case(37): makehatshop(global.hat037,floor(375 * global.hatmerchantdiscount),37) break;
//Viking
case(38): makehatshop(global.hat038,floor(112 * global.hatmerchantdiscount),38) break;
//Red Sus
case(39): makehatshop(global.hat040,floor(150 * global.hatmerchantdiscount),40) break;
//Yellow Sus
case(40): makehatshop(global.hat041,floor(112 * global.hatmerchantdiscount),41) break;
//Green Sus
case(41): makehatshop(global.hat042,floor(112 * global.hatmerchantdiscount),42) break;
//Blue Sus
case(42): makehatshop(global.hat043,floor(75 * global.hatmerchantdiscount),43) break;
//White Sus
case(43): makehatshop(global.hat044,floor(112 * global.hatmerchantdiscount),44) break;
//Serbian
case(44): makehatshop(global.hat047,floor(75 * global.hatmerchantdiscount),47) break;
//Rat Hat
case(45): makehatshop(global.hat048,floor(75 * global.hatmerchantdiscount),48) break;
//German Hat
case(46): makehatshop(global.hat049,floor(75 * global.hatmerchantdiscount),49) break;
//French Hat
case(47): makehatshop(global.hat050,floor(75 * global.hatmerchantdiscount),50) break;
//Italian Hat
case(48): makehatshop(global.hat051,floor(75 * global.hatmerchantdiscount),51) break;
//Spanish Hat
case(49): makehatshop(global.hat052,floor(75 * global.hatmerchantdiscount),52) break;
//Magyar Hat
case(50): makehatshop(global.hat053,floor(75 * global.hatmerchantdiscount),53) break;
//Bosnian Hat
case(51): makehatshop(global.hat054,floor(75 * global.hatmerchantdiscount),54) break;
//Chinese Hat
case(52): makehatshop(global.hat055,floor(75 * global.hatmerchantdiscount),55) break;
//Ukrainian Hat
case(53): makehatshop(global.hat056,floor(75 * global.hatmerchantdiscount),56) break;
//Macedonian Hat
case(54): makehatshop(global.hat057,floor(75 * global.hatmerchantdiscount),57) break;
//Chicken Hat
case(55): makehatshop(global.hat058,floor(100 * global.hatmerchantdiscount),58) break;
//Czech Hat
case(56): makehatshop(global.hat059,floor(75 * global.hatmerchantdiscount),59) break;
//Russia Hat
case(57): makehatshop(global.hat060,floor(75 * global.hatmerchantdiscount),60) break;
//Devil Hat
case(58): makehatshop(global.hat061,floor(75 * global.hatmerchantdiscount),61) break;
//Turkish Hat
case(59): makehatshop(global.hat062,floor(75 * global.hatmerchantdiscount),62) break;
}
}

//Pressing/Holding Left
if os_type != os_android {
if RLselectedhat != 0 {
if !keyboard_check(vk_right) {
if keyboard_check(vk_left) {
if press = 0 {
selectedhat += 1
press = 1
} else {
holdcooldown -= 1 * (60 / global.maxfps)
if holdcooldown < 0 {
selectedhat += 1
holdcooldown = 4
}
}

}
}
}

if keyboard_check_released(vk_left) {
press = 0
holdcooldown = 40
}

//Pressing/Holding Right
if RLselectedhat != limithat {
if !keyboard_check(vk_left) {
if keyboard_check(vk_right) {
if press = 0 {
selectedhat -= 1
press = 1
} else {
holdcooldown -= 1 * (60 / global.maxfps)
if holdcooldown < 0 {
selectedhat -= 1
holdcooldown = 4
}
}

}
}
}

if keyboard_check_released(vk_right) {
press = 0
holdcooldown = 40
}
} else {
	
	if RLselectedhat != 0 {
	if key_left {
		selectedhat += 1
		instance_destroy(o_indicatorandroid)
	}}
	if RLselectedhat != limithat {
	if key_right {
		selectedhat -= 1
		instance_destroy(o_indicatorandroid)
	}}
}
