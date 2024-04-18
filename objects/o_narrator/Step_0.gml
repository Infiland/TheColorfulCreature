if global.pause = 0 {
l += 0.5 * (60 / global.maxfps);
if room = r_boss1prepare { l -= 0.3 * (60 / global.maxfps) }
if room = r_boss2prepare { l -= 0.3 * (60 / global.maxfps) }
if room = r_boss3prepare { l -= 0.3 * (60 / global.maxfps) }
if room = r_lvl30 { l -= 0.2 * (60 / global.maxfps) }
if room = r_lvl60 { l -= 0.2 * (60 / global.maxfps) }
if room = r_lvl69 { l -= 0.2 * (60 / global.maxfps) }
}
print = string_copy(str,1,l);

switch(room) {
default: str = "" break;
case(r_lvl1):
if global.hardmode = 0 {
	str = strings[0]
} else { str = strings[1] }
break;
case(r_lvl2):
if global.hardmode = 0 {
	str = strings[2]
} else { str = strings[3] }
break;
case(r_lvl3): str = strings[4] break;
case(r_lvl4): str = strings[5] break;
case(r_lvl5):
if global.hardmode = 0 {
	str = strings[6]
} else { str = strings[7] }
break;
case(r_lvl6):
if global.special < 5 { str = strings[8] }
if global.special = 5 { str = strings[9] }
if global.special = 6 { str = strings[10] }
break;
case(r_lvl7): if global.special < 7 { str = strings[11] } else { str = strings[12] } break;
case(r_lvl8): if global.special < 8 { str = strings[13] } else { str = strings[14] } break;
case(r_lvl9): if global.special < 9 { str = strings[15] } else { str = strings[16] } break;
case(r_lvl10): if global.special < 10 { str = strings[17] } else { str = strings[18] } break;
case(r_lvl11): str = strings[19] break;
case(r_lvl12): str = strings[20] break;
case(r_lvl13): str = strings[21] break;
case(r_lvl14):
if global.hardmode = 0 {str = strings[22]} else { str = strings[23] } break;
case(r_lvl15): str = strings[24] break;
case(r_lvl16): str = strings[25] break;
case(r_lvl17): str = strings[26] break;
case(r_lvl18): str = strings[27] break;
case(r_lvl19): str = strings[28] break;
case(r_lvl20): str = strings[29] break;
case(r_boss1prepare): str = strings[30] break;
case(r_boss2prepare): str = strings[30] break;
case(r_boss3prepare): str = strings[30] break;
case(r_boss4prepare): str = strings[30] break;
case(r_boss1): if global.boss1 = 0 { str = strings[31] } else { str = strings[32] } break;
case(r_lvl21): str = strings[33] break;
case(r_lvl22): str = strings[34] break;
case(r_lvl23): str = strings[35] break;
case(r_lvl24): str = strings[36] break;
case(r_lvl25): str = strings[37] break;
case(r_lvl26): str = strings[38] break;
case(r_lvl27): str = strings[39] break;
case(r_lvl28): str = strings[40] break;
case(r_lvl29): str = strings[41] break;
case(r_lvl30): str = strings[42] break;
case(r_lvl31): str = strings[43] break;
case(r_lvl32): str = strings[44] break;
case(r_lvl33): str = strings[45] break;
case(r_lvl34): str = strings[46] break;
case(r_lvl35): str = strings[47] break;
case(r_lvl36): controls_key_display(global.controlsinteract)
str = strings[48] break;
case(r_lvl37): str = strings[49] break;
case(r_lvl38): str = strings[50] break;
case(r_lvl39): str = strings[51] break;
case(r_lvl40): str = strings[52] break;
case(r_boss2): if global.boss2health != 1 { str = strings[53] } else { str = strings[54] }  break;

case(r_lvl41): str = strings[55] break;
case(r_lvl42): controls_key_display(global.controlsrestart)
str = strings[56] break;
case(r_lvl43): str = strings[57] break;
case(r_lvl44): str = strings[58] break;
case(r_lvl45): str = strings[59] break;
case(r_lvl46): str = strings[60] break;
case(r_lvl47): str = strings[61] break;
case(r_lvl48): str = strings[62] break;
case(r_lvl49): str = strings[63] break;
case(r_lvl50): str = strings[64] break;
case(r_lvl51): str = strings[65] break;
case(r_lvl52): str = strings[66] break;
case(r_lvl53): str = strings[67] break;
case(r_lvl54): str = strings[68] break;
case(r_lvl55): str = strings[69] break;
case(r_lvl56): str = strings[70] break;
case(r_lvl57): str = strings[71] break;
case(r_lvl58): str = strings[72] break;
case(r_lvl59): str = strings[73] break;
case(r_lvl60): str = strings[74] break;
case(r_boss3): str = strings[75] break;

case(r_lvl61): str = strings[76] break;
case(r_lvl62): str = strings[77] break;
case(r_lvl63): str = strings[78] break;
case(r_lvl64): str = strings[79] break;
case(r_lvl65): str = strings[80] break;
case(r_lvl66): str = strings[81] break;
case(r_lvl67): str = strings[82] break;
case(r_lvl68): str = strings[83] break;
case(r_lvl69): str = strings[84] break;
case(r_lvl70): str = strings[85] break;
case(r_lvl71): str = strings[86] break;
case(r_lvl72): str = strings[87] break;
case(r_lvl73): str = strings[88] break;
case(r_lvl74): str = strings[89] break;
case(r_lvl75): str = strings[90] break;
case(r_lvl76): str = strings[91] break;
case(r_lvl77): str = strings[92] break;
case(r_lvl78): str = strings[93] break;
case(r_lvl79): str = strings[94] break;
case(r_lvl80): str = strings[95] break;
case(r_boss4): str = strings[241] break;

case(r_lvl81): str = strings[96] break;
case(r_lvl82): str = strings[97] break;
case(r_lvl83): str = strings[98] break;
case(r_lvl84): str = strings[99] break;
case(r_lvl85): str = strings[100] break;
case(r_lvl86): str = strings[101] break;
case(r_taleroom): 
if global.hardmode = 0 {
if global.talelistened = 0 { str = strings[102] } else { str = strings[104] }
} else { str = strings[103] }
break;

case(r_lvl87): str = strings[133] break;
case(r_lvl88): str = strings[134] break;
case(r_lvl89): str = strings[135] break;
case(r_lvl90): controls_key_display(global.controlsinteract)
str = strings[136] break;
case(r_lvl91): str = strings[137] break;
case(r_lvl92): str = strings[138] break;
case(r_lvl93): str = strings[166] break;
case(r_lvl94): str = strings[183] break;
case(r_lvl95): str = strings[184] break;
case(r_lvl96): str = strings[185] break;
case(r_lvl97): str = strings[186] break;
case(r_lvl98): str = strings[187] break;
case(r_lvl99): str = strings[195] break;
case(r_lvl100): if global.level100trap = 0 { str = strings[196] } else { str = strings[197] } break;
case(r_hatmerchantroom): str = strings[207] break;
case(r_easteregg1): str = strings[206] break;
//KAIZO
case(r_kaizolvl1): str = strings[105] break;
case(r_kaizolvl2): str = strings[106] break;
case(r_kaizolvl3): str = strings[107] break;
case(r_kaizolvl4): str = strings[108] break;
case(r_kaizolvl5): str = strings[109] break;
//BLIND
case(r_blindlvl1): str = strings[110] break;
case(r_blindlvl2): str = strings[111] break;
case(r_blindlvl3): str = strings[112] break;
case(r_blindlvl4): str = strings[113] break;
case(r_blindlvl5): str = strings[114] break;
case(r_blindlvl6): str = strings[115] break;
case(r_blindlvl7): str = strings[116] break;
//BIG
case(r_bigroomlvl1): str = strings[117] break;
case(r_bigroomlvl2): str = strings[118] break;
case(r_bigroomlvl3): str = strings[119] break;
//TROOP
case(r_trooplvl1): str = strings[120] break;
case(r_trooplvl2): str = strings[121] break;
case(r_trooplvl3): str = strings[122] break;
case(r_trooplvl4): str = strings[123] break;
case(r_trooplvl5): str = strings[124] break;
//SLIPPERY
case(r_slipperylvl1): str = strings[125] break;
case(r_slipperylvl2): str = strings[126] break;
case(r_slipperylvl3): str = strings[127] break;
case(r_slipperylvl4): str = strings[128] break;
case(r_slipperylvl5): str = strings[129] break;
case(r_slipperylvl6): controls_key_display(global.controlsinteract)
str = strings[130] break;
case(r_slipperylvl7): str = strings[131] break;
case(r_slipperylvl8): str = strings[132] break;
//SPEED
case(r_speedlvl1): str = strings[139] break;
case(r_speedlvl2): str = strings[140] break;
case(r_speedlvl3): str = strings[141] break;
case(r_speedlvl4): str = strings[142] break;
case(r_speedlvl5): str = strings[143] break;
case(r_speedlvl6): str = strings[144] break;
case(r_speedlvl7): str = strings[145] break;
//WORLD 6
case(r_world6lvl1): str = strings[146] break;
case(r_world6lvl2): str = strings[147] break;
case(r_world6lvl3): str = strings[148] break;
case(r_world6lvl4): str = strings[149] break;
case(r_world6lvl5): str = strings[150] break;
case(r_world6lvl6): str = strings[151] break;
case(r_world6lvl7): str = strings[152] break;
case(r_world6lvl8): str = strings[153] break;
case(r_world6lvl9): str = strings[154] break;
case(r_world6lvl10): str = strings[155] break;
case(r_world6lvl11): str = strings[156] break;
case(r_world6lvl12): str = strings[157] break;
case(r_world6lvl13): str = strings[158] break;
case(r_world6lvl14): str = strings[159] break;
case(r_world6lvl15): str = strings[160] break;
case(r_world6lvl16): str = strings[161] break;
case(r_world6lvl17): str = strings[162] break;
case(r_world6lvl18): str = strings[163] break;
case(r_world6lvl19): str = strings[164] break;
case(r_world6lvl20): str = strings[165] break;
//LADDER
case(r_ladderlvl1): str = strings[167] break;
case(r_ladderlvl2): str = strings[168] break;
case(r_ladderlvl3): str = strings[169] break;
case(r_ladderlvl4): str = strings[170] break;
case(r_ladderlvl5): str = strings[171] break;
case(r_ladderlvl6): str = strings[172] break;
case(r_ladderlvl7): str = strings[173] break;
case(r_ladderlvl8): str = strings[174] break;
case(r_ladderlvl9): str = strings[175] break;
case(r_ladderlvl10): str = strings[176] break;
//TUTORIAL
case(r_tutoriallvl1): str = strings[177] break;
case(r_tutoriallvl2): str = strings[178] break;
case(r_tutoriallvl3): str = strings[179] break;
case(r_tutoriallvl4): str = strings[180] break;
case(r_tutoriallvl5): str = strings[181] break;
case(r_tutoriallvl6): str = strings[182] break;
//SPIKE
case(r_spikelvl1): str = strings[188] break;
case(r_spikelvl2): str = strings[189] break;
case(r_spikelvl3): str = strings[190] break;
case(r_spikelvl4): str = strings[191] break;
case(r_spikelvl5): str = strings[192] break;
case(r_spikelvl6): str = strings[193] break;
case(r_spikelvl7): str = strings[194] break;
//WATER
case(r_waterlvl1): str = strings[198] break;
case(r_waterlvl2): str = strings[199] break;
case(r_waterlvl3): str = strings[200] break;
case(r_waterlvl4): str = strings[201] break;
case(r_waterlvl5): str = strings[202] break;
case(r_waterlvl6): str = strings[203] break;
case(r_waterlvl7): str = strings[204] break;
case(r_waterlvl8): str = strings[205] break;
//MOVING
case(r_movinglvl1): str = strings[208] break;
case(r_movinglvl2): str = strings[209] break;
case(r_movinglvl3): str = strings[210] break;
case(r_movinglvl4): str = strings[211] break;
case(r_movinglvl5): str = strings[212] break;
case(r_movinglvl6): str = strings[213] break;
case(r_movinglvl7): str = strings[214] break;
//COMMUNITY
case(r_communitylvl1): str = strings[215] break;
case(r_communitylvl2): str = strings[216] break;
case(r_communitylvl3): str = strings[217] break;
case(r_communitylvl4): str = strings[218] break;
case(r_communitylvl5): str = strings[219] break;
case(r_communitylvl6): str = strings[220] break;
case(r_communitylvl7): str = strings[221] break;
//D.JUMP
case(r_djlvl1): str = strings[223] break;
case(r_djlvl2): str = strings[224] break;
case(r_djlvl3): str = strings[225] break;
case(r_djlvl4): str = strings[226] break;
case(r_djlvl5): str = strings[227] break;
case(r_djlvl6): str = strings[228] break;
case(r_djlvl7): str = strings[229] break;
case(r_djlvl8): str = strings[230] break;
case(r_djlvl9): str = strings[231] break;
//C.SPIKE
case(r_cslvl1): str = strings[232] break;
case(r_cslvl2): str = strings[233] break;
case(r_cslvl3): str = strings[234] break;
case(r_cslvl4): str = strings[235] break;
case(r_cslvl5): str = strings[236] break;
case(r_cslvl6): str = strings[237] break;
case(r_cslvl7): str = strings[238] break;
case(r_cslvl8): str = strings[239] break;
case(r_cslvl9): str = strings[240] break;
//WORLD 7
case(r_world7lvl1): str = strings[242] break;
case(r_world7lvl2): str = strings[243] break;
case(r_world7lvl3): str = strings[244] break;
case(r_world7lvl4): str = strings[245] break;
case(r_world7lvl5): str = strings[246] break;
case(r_world7lvl6): str = strings[247] break;
case(r_world7lvl7): str = strings[248] break;
case(r_world7lvl8): str = strings[249] break;
case(r_world7lvl9): str = strings[250] break;
case(r_world7lvl10): str = strings[251] break;
case(r_world7lvl11): str = strings[252] break;
case(r_world7lvl12): str = strings[253] break;
case(r_world7lvl13): str = strings[254] break;
case(r_world7lvl14): str = strings[255] break;
case(r_world7lvl15): str = strings[256] break;
case(r_world7lvl16): str = strings[257] break;
case(r_world7lvl17): str = strings[258] break;
case(r_world7lvl18): str = strings[259] break;
case(r_world7lvl19): str = strings[260] break;
case(r_world7lvl20): str = strings[261] break;

case(r_customlevelworkshop): str = strings[262] break;

case(r_invisiblelvl1): str = strings[263] break;
case(r_invisiblelvl2): str = strings[264] break;
case(r_invisiblelvl3): str = strings[265] break;
case(r_invisiblelvl4): str = strings[266] break;
case(r_invisiblelvl5): str = strings[267] break;
case(r_invisiblelvl6): str = strings[268] break;

case(r_breakablelvl1): str = strings[270] break;
case(r_breakablelvl2): str = strings[271] break;
case(r_breakablelvl3): str = strings[272] break;
case(r_breakablelvl4): str = strings[273] break;
case(r_breakablelvl5): str = strings[274] break;
case(r_breakablelvl6): str = strings[275] break;
}

if global.calendar = 1 { str = strings[269] }