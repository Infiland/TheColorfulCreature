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
if global.skin[48] = 1 {draw_text_ext(32,704,loc(630),20,820) }
break;
case(49):
if global.skin[49] = 0 {draw_text_ext(32,704,CALENDARSKINUNLOCK,20,820) }
if global.skin[49] = 1 {draw_text_ext(32,704,loc(679),20,820) }
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
case(1): draw_text(32,704,loc(404)) break;
case(2):
if global.hat[1] = -1 {draw_text(32,704,loc(405))}
if global.hat[1] = 0 {draw_text(32,704,HATAVAILABLE)}
if global.hat[1] = 1 {draw_text(32,704,loc(406))}
break;
case(3):
if global.hat[2] = 0 {draw_text(32,704,HATAVAILABLE)}
if global.hat[2] = 1 {draw_text(32,704,loc(407))}
break;
case(4):
if global.hat[3] = -1 {draw_text(32,704,loc(408)) }
if global.hat[3] = 0 {draw_text(32,704,HATAVAILABLE)}
if global.hat[3] = 1 {draw_text(32,704,loc(409))}
break;
case(5):
if global.hat[4] = 0 {draw_text(32,704,HATAVAILABLE)}
if global.hat[4] = 1 {draw_text(32,704,loc(410))}
break;
case(6):
if global.hat[5] = 0 {draw_text(32,704,HATAVAILABLE)}
if global.hat[5] = 1 {draw_text(32,704,loc(411))}
break;
case(7):
if global.hat[6] = 0 {draw_text(32,704,"Hat available at the hat merchant. It's expensive though!")}
if global.hat[6] = 1 {draw_text(32,704,loc(412))}
break;
case(8):
if global.hat[7] = 0 {draw_text(32,704,HATAVAILABLE)}
if global.hat[7] = 1 {draw_text(32,704,loc(413))}
break;
case(9):
if global.hat[8] = -1 {draw_text(32,704,loc(414))}
if global.hat[8] = 0 {draw_text(32,704,HATAVAILABLE)}
if global.hat[8] = 1 {draw_text(32,704,loc(415))}
break;
case(10):
if global.hat[9] = -1 {draw_text(32,704,loc(416))}
if global.hat[9] = 0 {draw_text(32,704,HATAVAILABLE)}
if global.hat[9] = 1 {draw_text(32,704,loc(417))}
break;
case(11):
if global.hat[10] = -1 {draw_text(32,704,loc(416))}
if global.hat[10] = 0 {draw_text(32,704,HATAVAILABLE)}
if global.hat[10] = 1 {draw_text(32,704,loc(418))}
break;
case(12):
if global.hat[11] = 0 {draw_text(32,704,HATAVAILABLE)}
if global.hat[11] = 1 {draw_text(32,704,loc(419))}
break;
case(13):
if global.hat[12] = 0 {draw_text(32,704,HATAVAILABLE)}
if global.hat[12] = 1 {draw_text(32,704,loc(420))}
break;
case(14):
if global.hat[13] = 0 {draw_text(32,704,HATAVAILABLE)}
if global.hat[13] = 1 {draw_text(32,704,loc(421))}
break;
case(15):
if global.hat[14] = 0 {draw_text(32,704,HATAVAILABLE)}
if global.hat[14] = 1 {draw_text(32,704,loc(422))}
break;
case(16):
if global.hat[15] = 0 {draw_text(32,704,HATAVAILABLE)}
if global.hat[15] = 1 {draw_text(32,704,loc(423))}
break;
case(17):
if global.hat[16] = 0 {draw_text(32,704,HATAVAILABLE)}
if global.hat[16] = 1 {draw_text(32,704,loc(424))}
break;
case(18):
if global.hat[17] = 0 {draw_text(32,704,HATAVAILABLE)}
if global.hat[17] = 1 {draw_text(32,704,loc(425))}
break;
case(19):
if global.hat[18] = 0 {draw_text(32,704,HATAVAILABLE)}
if global.hat[18] = 1 {draw_text(32,704,loc(426))}
break;
case(20):
if global.hat[19] = 0 {draw_text(32,704,HATAVAILABLE)}
if global.hat[19] = 1 {draw_text(32,704,loc(427))}
break;
case(21):
if global.hat[20] = 0 {draw_text(32,704,HATAVAILABLE)}
if global.hat[20] = 1 {draw_text(32,704,loc(428))}
break;
case(22):
if global.hat[21] = 0 {draw_text(32,704,HATAVAILABLE)}
if global.hat[21] = 1 {draw_text(32,704,loc(429))}
break;
case(23):
if global.hat[22] = 0 {draw_text(32,704,HATAVAILABLE)}
if global.hat[22] = 1 {draw_text(32,704,loc(430))}
break;
case(24):
if global.hat[23] = 0 {draw_text(32,704,HATAVAILABLE)}
if global.hat[23] = 1 {draw_text(32,704,loc(431))}
break;
case(25):
if global.hat[24] = 0 {	draw_text(32,704,HATAVAILABLE)}
if global.hat[24] = 1 {	draw_text(32,704,loc(432))}
break;
case(26):
if global.hat[25] = 0 {	draw_text(32,704,HATAVAILABLE)}
if global.hat[25] = 1 {	draw_text(32,704,loc(433))}
break;
case(27):
if global.hat[26] = 0 {	draw_text(32,704,HATAVAILABLE)}
if global.hat[26] = 1 {	draw_text(32,704,loc(434))}
break;
case(28):
if global.hat[27] = 0 {	draw_text(32,704,HATAVAILABLE)}
if global.hat[27] = 1 {	draw_text(32,704,loc(435))}
break;
case(29):
if global.hat[28] = 0 {	draw_text(32,704,HATAVAILABLE)}
if global.hat[28] = 1 {	draw_text(32,704,loc(436))}
break;
case(30):
if global.hat[29] = 0 {	draw_text(32,704,HATAVAILABLE)}
if global.hat[29] = 1 {	draw_text(32,704,loc(437))}
break;
case(31):
if global.hat[30] = 0 {	draw_text(32,704,HATAVAILABLE)}
if global.hat[30] = 1 {	draw_text(32,704,loc(438))}
break;
case(32):
if global.hat[31] = 0 {	draw_text(32,704,HATAVAILABLE)}
if global.hat[31] = 1 {	draw_text(32,704,loc(439))}
break;
case(33):
if global.hat[32] = 0 {	draw_text(32,704,HATAVAILABLE)}
if global.hat[32] = 1 {	draw_text(32,704,loc(601))}
break;
case(34):
if global.hat[33] = 0 {	draw_text(32,704,HATAVAILABLE)}
if global.hat[33] = 1 {	draw_text(32,704,loc(587))}
break;
case(35):
if global.hat[34] = 0 {	draw_text(32,704,HATAVAILABLE)}
if global.hat[34] = 1 {	draw_text(32,704,loc(595))}
break;
case(36):
if global.hat[35] = -1 {	draw_text(32,704,"Beat the game to unlock this hat!")}
if global.hat[35] = 0 {	draw_text(32,704,HATAVAILABLE)}
if global.hat[35] = 1 {	draw_text(32,704,loc(596))}
break;
case(37):
if global.hat[36] = 0 {	draw_text(32,704,HATAVAILABLE)}
if global.hat[36] = 1 {	draw_text(32,704,loc(600))}
break;
case(38):
if global.hat[37] = 0 {	draw_text(32,704,HATAVAILABLE)}
if global.hat[37] = 1 {	draw_text(32,704,loc(603))}
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
if global.hat[47] = 1 {	draw_text_scribble(32,704,"[wave]"+loc(648)) }
break;
case(49):
if global.hat[48] = 0 {	draw_text(32,704,HATAVAILABLE)}
if global.hat[48] = 1 {	draw_text_scribble(32,704,loc(647)) }
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
if global.hat[54] = 1 {	draw_text_scribble(32,704,"Thank you for translating TCC in SRB/CRO/BOS!") }
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
case(1): draw_text(32,704,loc(626)) break;
case(2):
if global.item[1] = 0 {	draw_text(32,704,CALENDARITEMUNLOCK)}
if global.item[1] = 1 {	draw_text(32,704,loc(627)) }
break;
case(3):
if global.item[2] = 0 {	draw_text(32,704,CALENDARITEMUNLOCK)}
if global.item[2] = 1 {	draw_text(32,704,loc(628)) }
break;
case(4):
if global.item[3] = 0 {	draw_text(32,704,CALENDARITEMUNLOCK)}
if global.item[3] = 1 {	draw_text(32,704,loc(629)) }
break;
}
break;

}
}