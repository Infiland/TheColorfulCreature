draw_set_font(global.deathfont)
draw_set_color(c_white)
//Settings
if room = r_settings || instance_exists(o_settingspausemenu) {
	draw_text_ext(32,704,SETTING[global.infosettings],20,960)
}

//Skins
if room = r_skinmenu {
	
switch(global.customizeselect) {

case(1):
switch(global.skininfo) {
case(0): draw_text(32,704,SETTING[0]) break;
case(1):
if global.skin[1] = 1 {draw_text_ext(32,704,SKIN1_1,20,820) }
if global.skin[1] = 0 {draw_text_ext(32,704,SKIN1_0,20,820) }
break;
case(2):
if global.skin[2] = 0 {draw_text_ext(32,704,SKIN2_0,20,820)}
if global.skin[2] = 1 {draw_text_ext(32,704,SKIN2_1,20,820)}
break;
case(3):
if global.skin[3] = 0 {draw_text_ext(32,704,SKIN3_0,20,820)}
if global.skin[3] = 1 {draw_text_ext(32,704,SKIN3_1,20,820)}
break;
case(4):
if global.skin[4] = 0 {draw_text_ext(32,704,SKIN4_0,20,820)}
if global.skin[4] = 1 {draw_text_ext(32,704,SKIN4_1,20,820)}
break;
case(5):
if global.skin[5] = 0 {draw_text_ext(32,704,SKIN5_0,20,820)}
if global.skin[5] = 1 {draw_text_ext(32,704,SKIN5_1,20,820)}
break;
case(6):
if global.skin[6] = 0 {	draw_text_ext(32,704,SKIN6_0,20,820)}
if global.skin[6] = 1 {draw_text_ext(32,704,SKIN6_1,20,820)}
break;
case(7):
if global.skin[7] = 0 {draw_text_ext(32,704,SKIN7_0,20,820)}
if global.skin[7] = 1 {draw_text_ext(32,704,SKIN7_1,20,820)}
break;
case(8):
if global.skin[8] = 0 {draw_text_ext(32,704,SKIN8_0,20,820)}
if global.skin[8] = 1 {draw_text_ext(32,704,SKIN8_1,20,820)}
break;
case(9):
if global.skin[9] = 0 {draw_text_ext(32,704,SKIN9_0,20,820)}
if global.skin[9] = 1 {draw_text_ext(32,704,SKIN9_1,20,820)}
break;
case(10):
if global.skin[10] = 0 {draw_text_ext(32,704,SKIN10_0,20,820)}
if global.skin[10] = 1 {draw_text_ext(32,704,SKIN10_1,20,820)}
break;
case(11):
if global.skin[11] = 0 {draw_text(32,704,"? ? ?")}
if global.skin[11] = 1 {draw_text_ext(32,704,SKIN11_1,20,820)}
break;
case(12):
if global.skin[12] = 0 {draw_text_ext(32,704,SKIN12_0,20,820)}
if global.skin[12] = 1 {draw_text_ext(32,704,SKIN12_1,20,820)}
break;
case(13):
if global.skin[13] = 0 {draw_text(32,704,"? ? ?")}
if global.skin[13] = 1 {draw_text_ext(32,704,SKIN13_1,20,820)}
break;
case(14):
if global.skin[14] = 0 {draw_text_ext(32,704,SKIN14_0,20,820)}
if global.skin[14] = 1 {draw_text_ext(32,704,SKIN14_1,20,820)}
break;
case(15):
if global.skin[15] = 0 {draw_text_ext(32,704,SKIN15_0,20,820)}
if global.skin[15] = 1 {draw_text_ext(32,704,SKIN15_1,20,820)}
break;
case(16):
if global.skin[16] = 0 {draw_text_ext(32,704,SKIN16_0,20,820)}
if global.skin[16] = 1 {draw_text_ext(32,704,SKIN16_1,20,820)}
break;
case(17):
if global.skin[17] = 0 {draw_text_ext(32,704,SKIN17_0,20,820)}
if global.skin[17] = 1 {draw_text_ext(32,704,SKIN17_1,20,820)}
break;
case(18):
if global.skin[18] = 0 {draw_text(32,704,"? ? ?")}
if global.skin[18] = 1 {draw_text_ext(32,704,SKIN18_1,20,820)}
break;
case(19):
if global.skin[19] = 0 {draw_text_ext(32,704,SKIN19_0,20,820)}
if global.skin[19] = 1 {draw_text_ext(32,704,SKIN19_1,20,820)}
break;
case(20):
if global.skin[20] = 0 {draw_text_ext(32,704,SKIN20_0,20,820)}
if global.skin[20] = 1 {draw_text_ext(32,704,SKIN20_1,20,820)}
break;
case(21):
if global.skin[21] = 0 {draw_text_ext(32,704,SKIN21_0,20,820)}
if global.skin[21] = 1 {draw_text_ext(32,704,SKIN21_1,20,820)}
break;
case(22):
if global.skin[22] = 0 {draw_text(32,704,"? ? ?")}
if global.skin[22] = 1 {draw_text_ext(32,704,SKIN22_1,20,820)}
break;
case(23):
if global.skin[23] = 0 {draw_text_ext(32,704,SKIN23_0,20,820)}
if global.skin[23] = 1 {draw_text_ext(32,704,SKIN23_1,20,820)}
break;
case(24):
if global.skin[24] = 0 {draw_text_ext(32,704,SKIN24_0,20,820)}
if global.skin[24] = 1 {
if instance_exists(o_forseneskinbutton) {
if o_forseneskinbutton.image_index = 0 { draw_text_ext(32,704,SKIN24_1,20,820)} else {
	draw_text_ext(32,704,SKIN24_2,20,820)
}
}
}
break;
case(25):
if global.skin[25] = 0 {draw_text(32,704,"? ? ?")}
if global.skin[25] = 1 {draw_text_ext(32,704,SKIN25_1,20,820)}
break;
case(26):
if global.skin[26] = 0 {draw_text_ext(32,704,SKIN26_0,20,820)}
if global.skin[26] = 1 {draw_text_ext(32,704,SKIN26_1,20,820)}
break;
case(27):
if global.skin[27] = 0 {draw_text_ext(32,704,SKIN27_0,20,820)}
if global.skin[27] = 1 {draw_text_ext(32,704,SKIN27_1,20,820)}
break;
case(28):
if global.skin[28] = 0 {draw_text_ext(32,704,SKIN28_0,20,820)}
if global.skin[28] = 1 {draw_text_ext(32,704,SKIN28_1,20,820)}
break;
case(29):
if global.skin[29] = 0 {draw_text_ext(32,704,SKIN29_0,20,820)}
if global.skin[29] = 1 {draw_text_ext(32,704,SKIN29_1,20,820)}
break;
case(30):
if global.skin[30] = 0 {draw_text_ext(32,704,SKIN30_0,20,820)}
if global.skin[30] = 1 {draw_text_ext(32,704,SKIN30_1,20,820)}
break;
case(31):
if global.skin[31] = 0 {draw_text_ext(32,704,SKIN31_0,20,820)}
if global.skin[31] = 1 {draw_text_ext(32,704,SKIN31_1,20,820)}
break;
case(32):
if global.skin[32] = 0 {draw_text_ext(32,704,SKIN32_0,20,820)}
if global.skin[32] = 1 {draw_text_ext(32,704,SKIN32_1,20,820)}
break;
case(33):
if global.skin[33] = 0 {draw_text_ext(32,704,SKIN33_0,20,820)}
if global.skin[33] = 1 {draw_text_ext(32,704,SKIN33_1,20,820)}
break;
case(34):
if global.skin[34] = 0 {draw_text_ext(32,704,SKIN34_0,20,820)}
if global.skin[34] = 1 {draw_text_ext(32,704,SKIN34_1,20,820)}
break;
case(35):
if global.skin[35] = 0 {draw_text(32,704,"? ? ?")}
if global.skin[35] = 1 {draw_text_ext(32,704,SKIN35_1,20,820)}
break;
case(36):
if global.skin[36] = 0 {draw_text_ext(32,704,SKIN36_0,20,820) }
if global.skin[36] = 1 {draw_text_ext(32,704,SKIN36_1,20,820) }
break;
case(37):
if global.skin[37] = 0 {draw_text_ext(32,704,SKIN37_0,20,820) }
if global.skin[37] = 1 {draw_text_ext(32,704,SKIN37_1,20,820) }
break;
case(38):
if global.skin[38] = 0 {draw_text_ext(32,704,SKIN38_0,20,820) }
if global.skin[38] = 1 {draw_text_ext(32,704,SKIN38_1,20,820) }
break;
case(39):
if global.skin[39] = 0 {draw_text_ext(32,704,SKIN39_0,20,820) }
if global.skin[39] = 1 {draw_text_ext(32,704,SKIN39_1,20,820) }
break;
case(40):
if global.skin[40] = 0 {draw_text_ext(32,704,SKIN40_0,20,820) }
if global.skin[40] = 1 {draw_text(32,704,"ARRRRRRRRGHHH!") }
break;
case(41):
if global.skin[41] = 0 {draw_text(32,704,"? ? ?") }
if global.skin[41] = 1 {draw_text(32,704,"Reddie 2077") }
break;
case(42):
if global.skin[42] = 0 {draw_text_ext(32,704,SKIN42_0,20,820) }
if global.skin[42] = 1 {draw_text_ext(32,704,SKIN42_1,20,820) }
break;
case(43):
if global.skin[43] = 0 {draw_text_ext(32,704,SKIN43_0,20,820) }
if global.skin[43] = 1 {draw_text_ext(32,704,SKIN43_1,20,820) }
break;
case(44):
if global.skin[44] = 0 {draw_text_ext(32,704,SKIN44_0,20,820) }
if global.skin[44] = 1 {draw_text_ext(32,704,SKIN44_1,20,820) }
break;
case(45):
if global.skin[45] = 0 {draw_text_ext(32,704,SKIN45_0,20,820) }
if global.skin[45] = 1 {draw_text_ext(32,704,SKIN45_1,20,820) }
break;
case(46):
if global.skin[46] = 0 {draw_text_ext(32,704,CALENDARSKINUNLOCK,20,820) }
if global.skin[46] = 1 {draw_text_ext(32,704,"He is staring at your soul... he is happy.",20,820) }
break;
case(47):
if global.skin[47] = 0 {draw_text_ext(32,704,CALENDARSKINUNLOCK,20,820) }
if global.skin[47] = 1 {draw_text_ext(32,704,"The worst skin in the game.",20,820) }
break;
case(48):
if global.skin[48] = 0 {draw_text_ext(32,704,CALENDARSKINUNLOCK,20,820) }
if global.skin[48] = 1 {draw_text_ext(32,704,loc("REDDIE_S_ON_FIRE"),20,820) }
break;
case(49):
if global.skin[49] = 0 {draw_text_ext(32,704,CALENDARSKINUNLOCK,20,820) }
if global.skin[49] = 1 {draw_text_ext(32,704,loc("BEWARE_OF_THE_CAMERAMEN_BIG_BROTHER_IS_WATCHING"),20,820) }
break;
case(50):
if global.skin[50] = 0 {draw_text_ext(32,704,CALENDARSKINUNLOCK,20,820) }
if global.skin[50] = 1 {draw_text_ext(32,704,"I do not need a snack.",20,820) }
break;
}
break;

//Hats
case(2):
switch(global.skininfo) {
case(1): draw_text(32,704,loc("UNEQUIP_A_HAT")) break;
case(2):
if global.hat[1] = -1 {draw_text(32,704,loc("BEAT_THE_TUTORIAL_CHALLENGE_TO_UNLOCK_THIS_HAT_IN_THE_HAT_ME"))}
if global.hat[1] = 0 {draw_text(32,704,HATAVAILABLE)}
if global.hat[1] = 1 {draw_text(32,704,loc("YOU_GRADUATED"))}
break;
case(3):
if global.hat[2] = 0 {draw_text(32,704,HATAVAILABLE)}
if global.hat[2] = 1 {draw_text(32,704,loc("ZOMBIES_WEAR_THIS"))}
break;
case(4):
if global.hat[3] = -1 {draw_text(32,704,loc("AVAILABLE_IN_THE_SHOP_ON_TCC_ANNIVERSARY_OR_ON_INFILAND_S_BI")) }
if global.hat[3] = 0 {draw_text(32,704,HATAVAILABLE)}
if global.hat[3] = 1 {draw_text(32,704,loc("IT_S_TIME_TO_PARTY"))}
break;
case(5):
if global.hat[4] = 0 {draw_text(32,704,HATAVAILABLE)}
if global.hat[4] = 1 {draw_text(32,704,loc("THESE_THINGS_ARE_OUT_OF_TREES"))}
break;
case(6):
if global.hat[5] = 0 {draw_text(32,704,HATAVAILABLE)}
if global.hat[5] = 1 {draw_text(32,704,loc("NOW_YOU_RE_A_GENTLEMEN"))}
break;
case(7):
if global.hat[6] = 0 {draw_text(32,704,"Hat available at the hat merchant. It's expensive though!")}
if global.hat[6] = 1 {draw_text(32,704,loc("NOW_YOU_RE_A_RICH_SUPER_GENTLEMEN"))}
break;
case(8):
if global.hat[7] = 0 {draw_text(32,704,HATAVAILABLE)}
if global.hat[7] = 1 {draw_text(32,704,loc("YOU_CAN_PUT_ANOTHER_REDDIE_ON_REDDIE"))}
break;
case(9):
if global.hat[8] = -1 {draw_text(32,704,loc("AVAILABLE_IN_THE_SHOP_ON_CHRISTMAS_BOTH_25TH_DEC_AND_7TH_JAN"))}
if global.hat[8] = 0 {draw_text(32,704,HATAVAILABLE)}
if global.hat[8] = 1 {draw_text(32,704,loc("HOO_HOO_HOO"))}
break;
case(10):
if global.hat[9] = -1 {draw_text(32,704,loc("AVAILABLE_IN_THE_SHOP_ON_HALLOWEEN"))}
if global.hat[9] = 0 {draw_text(32,704,HATAVAILABLE)}
if global.hat[9] = 1 {draw_text(32,704,loc("HOW_DO_I_MAKE_WITCH_SOUNDS"))}
break;
case(11):
if global.hat[10] = -1 {draw_text(32,704,loc("AVAILABLE_IN_THE_SHOP_ON_HALLOWEEN"))}
if global.hat[10] = 0 {draw_text(32,704,HATAVAILABLE)}
if global.hat[10] = 1 {draw_text(32,704,loc("SCARY"))}
break;
case(12):
if global.hat[11] = 0 {draw_text(32,704,HATAVAILABLE)}
if global.hat[11] = 1 {draw_text(32,704,loc("A_BASIC_BROWN_HAT"))}
break;
case(13):
if global.hat[12] = 0 {draw_text(32,704,HATAVAILABLE)}
if global.hat[12] = 1 {draw_text(32,704,loc("A_BASIC_GRAY_HAT"))}
break;
case(14):
if global.hat[13] = 0 {draw_text(32,704,HATAVAILABLE)}
if global.hat[13] = 1 {draw_text(32,704,loc("A_BASIC_WHITE_HAT"))}
break;
case(15):
if global.hat[14] = 0 {draw_text(32,704,HATAVAILABLE)}
if global.hat[14] = 1 {draw_text(32,704,loc("USE_THIS_WHEN_THE_WEATHER_IS_TOO_HOT_OR_JUST_AS_A_COSMETIC"))}
break;
case(16):
if global.hat[15] = 0 {draw_text(32,704,HATAVAILABLE)}
if global.hat[15] = 1 {draw_text(32,704,loc("IT_S_A_TRADITIONAL_RED_BLOCK"))}
break;
case(17):
if global.hat[16] = 0 {draw_text(32,704,HATAVAILABLE)}
if global.hat[16] = 1 {draw_text(32,704,loc("IT_S_A_TRADITIONAL_YELLOW_BLOCK"))}
break;
case(18):
if global.hat[17] = 0 {draw_text(32,704,HATAVAILABLE)}
if global.hat[17] = 1 {draw_text(32,704,loc("IT_S_A_TRADITIONAL_GREEN_BLOCK"))}
break;
case(19):
if global.hat[18] = 0 {draw_text(32,704,HATAVAILABLE)}
if global.hat[18] = 1 {draw_text(32,704,loc("IT_S_A_TRADITIONAL_BLUE_BLOCK"))}
break;
case(20):
if global.hat[19] = 0 {draw_text(32,704,HATAVAILABLE)}
if global.hat[19] = 1 {draw_text(32,704,loc("IT_S_A_TRADITIONAL_WHITE_BLOCK"))}
break;
case(21):
if global.hat[20] = 0 {draw_text(32,704,HATAVAILABLE)}
if global.hat[20] = 1 {draw_text(32,704,loc("IT_S_A_TRADITIONAL_SPIKE"))}
break;
case(22):
if global.hat[21] = 0 {draw_text(32,704,HATAVAILABLE)}
if global.hat[21] = 1 {draw_text(32,704,loc("IT_S_A_TRADITIONAL_INVISIBLE_SPIKE"))}
break;
case(23):
if global.hat[22] = 0 {draw_text(32,704,HATAVAILABLE)}
if global.hat[22] = 1 {draw_text(32,704,loc("IT_S_A_TRADITIONAL_VERTICAL_MOVING_SPIKE"))}
break;
case(24):
if global.hat[23] = 0 {draw_text(32,704,HATAVAILABLE)}
if global.hat[23] = 1 {draw_text(32,704,loc("IT_S_A_TRADITIONAL_HORIZONTAL_MOVING_SPIKE"))}
break;
case(25):
if global.hat[24] = 0 {	draw_text(32,704,HATAVAILABLE)}
if global.hat[24] = 1 {	draw_text(32,704,loc("HEXAGON"))}
break;
case(26):
if global.hat[25] = 0 {	draw_text(32,704,HATAVAILABLE)}
if global.hat[25] = 1 {	draw_text(32,704,loc("LET_S_GET_THAT_BREAD_THO"))}
break;
case(27):
if global.hat[26] = 0 {	draw_text(32,704,HATAVAILABLE)}
if global.hat[26] = 1 {	draw_text(32,704,loc("PROTECTS_YOU_FROM_RATATATATATATA"))}
break;
case(28):
if global.hat[27] = 0 {	draw_text(32,704,HATAVAILABLE)}
if global.hat[27] = 1 {	draw_text(32,704,loc("I_HOPE_YOU_HAVE_SHURIKENS_AT_YOUR_DISPOSAL"))}
break;
case(29):
if global.hat[28] = 0 {	draw_text(32,704,HATAVAILABLE)}
if global.hat[28] = 1 {	draw_text(32,704,loc("THIS_IS_A_COZY_RED_BEANIE"))}
break;
case(30):
if global.hat[29] = 0 {	draw_text(32,704,HATAVAILABLE)}
if global.hat[29] = 1 {	draw_text(32,704,loc("THIS_IS_A_COZY_YELLOW_BEANIE"))}
break;
case(31):
if global.hat[30] = 0 {	draw_text(32,704,HATAVAILABLE)}
if global.hat[30] = 1 {	draw_text(32,704,loc("THIS_IS_A_COZY_GREEN_BEANIE"))}
break;
case(32):
if global.hat[31] = 0 {	draw_text(32,704,HATAVAILABLE)}
if global.hat[31] = 1 {	draw_text(32,704,loc("THIS_IS_A_COZY_BLUE_BEANIE"))}
break;
case(33):
if global.hat[32] = 0 {	draw_text(32,704,HATAVAILABLE)}
if global.hat[32] = 1 {	draw_text(32,704,loc("THIS_IS_A_COZY_WHITE_BEANIE"))}
break;
case(34):
if global.hat[33] = 0 {	draw_text(32,704,HATAVAILABLE)}
if global.hat[33] = 1 {	draw_text(32,704,loc("CAPTAINS_ONLY"))}
break;
case(35):
if global.hat[34] = 0 {	draw_text(32,704,HATAVAILABLE)}
if global.hat[34] = 1 {	draw_text(32,704,loc("A_CUTE_BOWTIE"))}
break;
case(36):
if global.hat[35] = -1 {	draw_text(32,704,"Beat the game to unlock this hat!")}
if global.hat[35] = 0 {	draw_text(32,704,HATAVAILABLE)}
if global.hat[35] = 1 {	draw_text(32,704,loc("AFTER_KING_S_DEFEAT_HIS_CROWN_WAS_SOLD_TO_YOU_WEAR_IT_WITH_P"))}
break;
case(37):
if global.hat[36] = 0 {	draw_text(32,704,HATAVAILABLE)}
if global.hat[36] = 1 {	draw_text(32,704,loc("WHY_DOES_THIS_EXIST"))}
break;
case(38):
if global.hat[37] = 0 {	draw_text(32,704,HATAVAILABLE)}
if global.hat[37] = 1 {	draw_text(32,704,loc("FOR_COMRADES_FROM_THE_GLORY_DAYS"))}
break;
case(39):
if global.hat[38] = 0 {	draw_text(32,704,HATAVAILABLE)}
if global.hat[38] = 1 {	draw_text(32,704,"Vikings have cool boats.")}
break;
case(40):
if global.hat[39] = 0 {	draw_text(32,704,CALENDARHATUNLOCK)}
if global.hat[39] = 1 {	draw_text(32,704,"YEEEEEHAAAAAWWW.")}
break;
case(41):
if global.hat[40] = 0 {	draw_text(32,704,HATAVAILABLE)}
if global.hat[40] = 1 {	draw_text(32,704,"A weird red suspicious creature.")}
break;
case(42):
if global.hat[41] = 0 {	draw_text(32,704,HATAVAILABLE)}
if global.hat[41] = 1 {	draw_text(32,704,"A weird yellow suspicious creature.")}
break;
case(43):
if global.hat[42] = 0 {	draw_text(32,704,HATAVAILABLE)}
if global.hat[42] = 1 {	draw_text(32,704,"A weird green suspicious creature.")}
break;
case(44):
if global.hat[43] = 0 {	draw_text(32,704,HATAVAILABLE)}
if global.hat[43] = 1 {	draw_text(32,704,"A weird blue suspicious creature.")}
break;
case(45):
if global.hat[44] = 0 {	draw_text(32,704,HATAVAILABLE)}
if global.hat[44] = 1 {	draw_text(32,704,"A weird white suspicious creature.")}
break;
case(46):
if global.hat[45] = 0 {	draw_text(32,704,CALENDARHATUNLOCK)}
if global.hat[45] = 1 {	draw_text(32,704,"Flower Hat!") }
break;
case(47):
if global.hat[46] = 0 {	draw_text(32,704,CALENDARHATUNLOCK)}
if global.hat[46] = 1 {	draw_text(32,704,"If only you could fly.") }
break;
case(48):
if global.hat[47] = 0 {	draw_text(32,704,HATAVAILABLE)}
if global.hat[47] = 1 {	draw_text_scribble(32,704,"[wave]"+loc("NEVER_FORGOTTEN")) }
break;
case(49):
if global.hat[48] = 0 {	draw_text(32,704,HATAVAILABLE)}
if global.hat[48] = 1 {	draw_text_scribble(32,704,loc("R_PLACE_WAS_SOMETHING_SPECIAL_WASN_T_IT")) }
break;
case(50):
if global.hat[49] = 0 {	draw_text(32,704,HATAVAILABLE)}
if global.hat[49] = 1 {	draw_text_scribble(32,704,"Thank you for translating TCC in German!") }
break;
case(51):
if global.hat[50] = 0 {	draw_text(32,704,HATAVAILABLE)}
if global.hat[50] = 1 {	draw_text_scribble(32,704,"Thank you for translating TCC in French!") }
break;
case(52):
if global.hat[51] = 0 {	draw_text(32,704,HATAVAILABLE)}
if global.hat[51] = 1 {	draw_text_scribble(32,704,"Thank you for translating TCC in Italian!") }
break;
case(53):
if global.hat[52] = 0 {	draw_text(32,704,HATAVAILABLE)}
if global.hat[52] = 1 {	draw_text_scribble(32,704,"Thank you for translating TCC in Spanish!") }
break;
case(54):
if global.hat[53] = 0 {	draw_text(32,704,HATAVAILABLE)}
if global.hat[53] = 1 {	draw_text_scribble(32,704,"Thank you for translating TCC in Magyar!") }
break;
case(55):
if global.hat[54] = 0 {	draw_text(32,704,HATAVAILABLE)}
if global.hat[54] = 1 {	draw_text_scribble(32,704,"Thank you for translating TCC in CRO/BOS!") }
break;
case(56):
if global.hat[55] = 0 {	draw_text(32,704,HATAVAILABLE)}
if global.hat[55] = 1 {	draw_text_scribble(32,704,"Thank you for translating TCC in Chinese!") }
break;
case(57):
if global.hat[56] = 0 {	draw_text(32,704,HATAVAILABLE)}
if global.hat[56] = 1 {	draw_text_scribble(32,704,"Thank you for translating TCC in Ukrainian!") }
break;
case(58):
if global.hat[57] = 0 {	draw_text(32,704,HATAVAILABLE)}
if global.hat[57] = 1 {	draw_text_scribble(32,704,"Thank you for translating TCC in Macedonian!") }
break;
case(59):
if global.hat[58] = 0 {	draw_text(32,704,HATAVAILABLE)}
if global.hat[58] = 1 {	draw_text_scribble(32,704,"QUACK!") }
break;
}
break;


case(3): //ITEMS
switch(global.skininfo) {
case(1): draw_text(32,704,loc("UNEQUIP_A_ITEM")) break;
case(2):
if global.item[1] = 0 {	draw_text(32,704,CALENDARITEMUNLOCK)}
if global.item[1] = 1 {	draw_text(32,704,loc("PAINT_WITH_YOUR_PAINTBRUSH")) }
break;
case(3):
if global.item[2] = 0 {	draw_text(32,704,CALENDARITEMUNLOCK)}
if global.item[2] = 1 {	draw_text(32,704,loc("GIVE_THIS_TO_SOMEONE_YOU_LIKE")) }
break;
case(4):
if global.item[3] = 0 {	draw_text(32,704,CALENDARITEMUNLOCK)}
if global.item[3] = 1 {	draw_text(32,704,loc("WE_SHALL_DEFEND_OURSELVES")) }
break;
}
break;

}
}