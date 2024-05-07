//Hat Shop
scr_playercontrolsconfig()

RLselectedhat = selectedhat * -1

if os_type != os_android {
if interactcontrols = 0 {
key_interact = keyboard_check_pressed(ord(global.controlsinteract)) || (gamepad_button_check_pressed(0,gp_shoulderrb))
} else { key_interact = keyboard_check_pressed(global.controlsinteract) || (gamepad_button_check_pressed(0,gp_shoulderrb)) }

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
case(1): makehatshop(global.hat[1],floor(75 * global.hatmerchantdiscount),1) break;
//Cone Hat
case(2): makehatshop(global.hat[2],floor(75 * global.hatmerchantdiscount),2) break;
//Party Hat
case(3): makehatshop(global.hat[3],floor(112 * global.hatmerchantdiscount),3) break;
//Paper Hat
case(4): makehatshop(global.hat[4],floor(75 * global.hatmerchantdiscount),4) break;
//Top Hat
case(5): makehatshop(global.hat[5],floor(300 * global.hatmerchantdiscount),5) break;
//Golden Top Hat
case(6): makehatshop(global.hat[6],floor(2250 * global.hatmerchantdiscount),6) break;
//Reddie Top Hat
case(7): makehatshop(global.hat[7],floor(225 * global.hatmerchantdiscount),7)break;
//Christmas Hat
case(8): makehatshop(global.hat[8],floor(112 * global.hatmerchantdiscount),8) break;
//Witch Hat
case(9): makehatshop(global.hat[9],floor(112 * global.hatmerchantdiscount),9) break;
//Pumpkin Hat
case(10): makehatshop(global.hat[10],floor(112 * global.hatmerchantdiscount),10)break;
//Brown Hat
case(11): makehatshop(global.hat[11],floor(75 * global.hatmerchantdiscount),11) break;
//Gray Hat
case(12): makehatshop(global.hat[12],floor(75 * global.hatmerchantdiscount),12) break;
//White Hat
case(13): makehatshop(global.hat[13],floor(75 * global.hatmerchantdiscount),13) break;
//Sun Hat
case(14): makehatshop(global.hat[14],floor(75 * global.hatmerchantdiscount),14) break;
//Red Block Hat
case(15): makehatshop(global.hat[15],floor(75 * global.hatmerchantdiscount),15) break;
//Yellow Block Hat
case(16): makehatshop(global.hat[16],floor(75 * global.hatmerchantdiscount),16) break;
//Green Block Hat
case(17): makehatshop(global.hat[17],floor(75 * global.hatmerchantdiscount),17) break;
//Blue Block Hat
case(18): makehatshop(global.hat[18],floor(75 * global.hatmerchantdiscount),18) break;
//White Block Hat
case(19): makehatshop(global.hat[19],floor(75 * global.hatmerchantdiscount),19) break;
//Spike Hat
case(20): makehatshop(global.hat[20],floor(75 * global.hatmerchantdiscount),20) break;
//Invisible Spike Hat
case(21): makehatshop(global.hat[21],floor(112 * global.hatmerchantdiscount),21) break;
//Vertical Moving Spike Hat
case(22): makehatshop(global.hat[22],floor(112 * global.hatmerchantdiscount),22) break;
//Horizontal Moving Spike Hat
case(23): makehatshop(global.hat[23],floor(112 * global.hatmerchantdiscount),23) break;
//Hexagon Hat Icon
case(24): makehatshop(global.hat[24],floor(180 * global.hatmerchantdiscount),24) break;
//Bread Hat Icon
case(25): makehatshop(global.hat[25],floor(187 * global.hatmerchantdiscount),25) break;
//Soldier Hat Icon
case(26): makehatshop(global.hat[26],floor(112 * global.hatmerchantdiscount),26) break;
//Samurai Hat Icon
case(27): makehatshop(global.hat[27],floor(75 * global.hatmerchantdiscount),27) break;
//Red Beanie Hat Icon
case(28): makehatshop(global.hat[28],floor(112 * global.hatmerchantdiscount),28) break;
//Yellow Beanie Hat Icon
case(29): makehatshop(global.hat[29],floor(112 * global.hatmerchantdiscount),29) break;
//Green Beanie Hat Icon
case(30): makehatshop(global.hat[30],floor(112 * global.hatmerchantdiscount),30) break;
//Blue Beanie Hat Icon
case(31): makehatshop(global.hat[31],floor(112 * global.hatmerchantdiscount),31) break;
//White Beanie Hat Icon
case(32): makehatshop(global.hat[32],floor(112 * global.hatmerchantdiscount),32) break;
//Pirate Hat Icon
case(33): makehatshop(global.hat[33],floor(187 * global.hatmerchantdiscount),33) break;
//Pink Bowtie Hat Icon
case(34): makehatshop(global.hat[34],floor(75 * global.hatmerchantdiscount),34) break;
//King Hat Icon
case(35): makehatshop(global.hat[35],floor(749 * global.hatmerchantdiscount),35) break;
//Hair
case(36): makehatshop(global.hat[36],floor(150 * global.hatmerchantdiscount),36) break;
//Comrade
case(37): makehatshop(global.hat[37],floor(375 * global.hatmerchantdiscount),37) break;
//Viking
case(38): makehatshop(global.hat[38],floor(112 * global.hatmerchantdiscount),38) break;
//Red Sus
case(39): makehatshop(global.hat[40],floor(150 * global.hatmerchantdiscount),40) break;
//Yellow Sus
case(40): makehatshop(global.hat[41],floor(112 * global.hatmerchantdiscount),41) break;
//Green Sus
case(41): makehatshop(global.hat[42],floor(112 * global.hatmerchantdiscount),42) break;
//Blue Sus
case(42): makehatshop(global.hat[43],floor(75 * global.hatmerchantdiscount),43) break;
//White Sus
case(43): makehatshop(global.hat[44],floor(112 * global.hatmerchantdiscount),44) break;
//Serbian Hat
case(44): makehatshop(global.hat[47],floor(50 * global.hatmerchantdiscount),47) break;
//Rat Hat
case(45): makehatshop(global.hat[48],floor(75 * global.hatmerchantdiscount),48) break;
//German Hat
case(46): makehatshop(global.hat[49],floor(50 * global.hatmerchantdiscount),49) break;
//French Hat
case(47): makehatshop(global.hat[50],floor(50 * global.hatmerchantdiscount),50) break;
//Italian Hat
case(48): makehatshop(global.hat[51],floor(50 * global.hatmerchantdiscount),51) break;
//Spanish Hat
case(49): makehatshop(global.hat[52],floor(50 * global.hatmerchantdiscount),52) break;
//Magyar Hat
case(50): makehatshop(global.hat[53],floor(50 * global.hatmerchantdiscount),53) break;
//Bosnian Hat
case(51): makehatshop(global.hat[54],floor(50 * global.hatmerchantdiscount),54) break;
//Chinese Hat
case(52): makehatshop(global.hat[55],floor(50 * global.hatmerchantdiscount),55) break;
//Ukrainian Hat
case(53): makehatshop(global.hat[56],floor(50 * global.hatmerchantdiscount),56) break;
//Macedonian Hat
case(54): makehatshop(global.hat[57],floor(50 * global.hatmerchantdiscount),57) break;
//Chicken Hat
case(55): makehatshop(global.hat[58],floor(100 * global.hatmerchantdiscount),58) break;
//Czech Hat
case(56): makehatshop(global.hat[59],floor(50 * global.hatmerchantdiscount),59) break;
//Russia Hat
case(57): makehatshop(global.hat[60],floor(50 * global.hatmerchantdiscount),60) break;
//Devil Hat
case(58): makehatshop(global.hat[61],floor(75 * global.hatmerchantdiscount),61) break;
//Turkish Hat
case(59): makehatshop(global.hat[62],floor(50 * global.hatmerchantdiscount),62) break;
//Palestinian Hat
case(60): makehatshop(global.hat[63],floor(50 * global.hatmerchantdiscount),63) break;
//Slovenian Hat
case(61): makehatshop(global.hat[64],floor(50 * global.hatmerchantdiscount),64) break;
//Japanese Hat
case(62): makehatshop(global.hat[65],floor(50 * global.hatmerchantdiscount),65) break;
//Romanian Hat
case(63): makehatshop(global.hat[66],floor(50 * global.hatmerchantdiscount),66) break;
//Portuguese Hat
case(64): makehatshop(global.hat[67],floor(50 * global.hatmerchantdiscount),67) break;
}
}

//Pressing/Holding Left
if os_type != os_android {
if RLselectedhat != 0 {
	

if !keyboard_check(vk_right) || gamepad_button_check(0,gp_padr) {
if keyboard_check(vk_left) || gamepad_button_check(0,gp_padl) {
	
if press = 0 {
selectedhat += 1
press = 1
} else {
holdcooldown -= 1 * (60 / global.maxfps)
if holdcooldown < 0 {
selectedhat += 1
if !keyboard_check(vk_shift) {
holdcooldown = 4
}
}
}

}
}



}

if keyboard_check_released(vk_left) || gamepad_button_check_released(0,gp_padl) {
press = 0
if !keyboard_check(vk_shift) {
holdcooldown = 40
}
}

//Pressing/Holding Right
if RLselectedhat != limithat {
if !keyboard_check(vk_left) || !gamepad_button_check(0,gp_padl) {
if keyboard_check(vk_right) || gamepad_button_check(0,gp_padr) {
if press = 0 {
selectedhat -= 1
press = 1
} else {
holdcooldown -= 1 * (60 / global.maxfps)
if holdcooldown < 0 {
selectedhat -= 1
if !keyboard_check(vk_shift) {
holdcooldown = 4
}
}
}

}
}
}

if keyboard_check_released(vk_right) || gamepad_button_check_released(0,gp_padr) {
press = 0
if !keyboard_check(vk_shift) {
holdcooldown = 40
}
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
