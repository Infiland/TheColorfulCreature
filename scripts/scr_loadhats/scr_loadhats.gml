function scr_loadhats() {
if global.cheats = 0 {
	
	var directory = directory_set("//Save Files/")
	
	if (file_exists(directory + "Hats.sav")) {
	ini_open(directory + "Hats.sav");
	global.hatselected = ini_read_real("Hats","Selected Hat",0)
	global.hatnameobjectselected = ini_read_real("Hats","Hat Name Object Selected",o_unequipedhatbutton)
	global.hat[1] = ini_read_real("Hats","Graduated Hat",-1)
	global.hat[2] = ini_read_real("Hats","Cone Hat",0)
	global.hat[3] = ini_read_real("Hats","Party Hat",-1)
	global.hat[4] = ini_read_real("Hats","Paper Hat",0)
	global.hat[5] = ini_read_real("Hats","Top Hat",0)
	global.hat[6] = ini_read_real("Hats","Yellow Top Hat",0)
	global.hat[7] = ini_read_real("Hats","Reddie Hat",0)
	global.hat[8] = ini_read_real("Hats","Christmas Hat",-1)
	global.hat[9] = ini_read_real("Hats","Witch Hat",-1)
	global.hat[10] = ini_read_real("Hats","Pumpkin Hat",-1)
	global.hat[11] = ini_read_real("Hats","Brown Cap",0)
	global.hat[12] = ini_read_real("Hats","Gray Cap",0)
	global.hat[13] = ini_read_real("Hats","White Cap",0)
	global.hat[14] = ini_read_real("Hats","Sun Hat",0)
	global.hat[15] = ini_read_real("Hats","Red Block Hat",0)
	global.hat[16] = ini_read_real("Hats","Yellow Block Hat",0)
	global.hat[17] = ini_read_real("Hats","Green Block Hat",0)
	global.hat[18] = ini_read_real("Hats","Blue Block Hat",0)
	global.hat[19] = ini_read_real("Hats","White Block Hat",0)
	global.hat[20] = ini_read_real("Hats","Spike Hat",0)
	global.hat[21] = ini_read_real("Hats","Invisible Spike Hat",0)
	global.hat[22] = ini_read_real("Hats","Vertical Moving Spike Hat",0)
	global.hat[23] = ini_read_real("Hats","Horizontal Moving Spike Hat",0)
	global.hat[24] = ini_read_real("Hats","Hexagon Hat",0)
	global.hat[25] = ini_read_real("Hats","Bread Hat",0)
	global.hat[26] = ini_read_real("Hats","Soldier Hat",0)
	global.hat[27] = ini_read_real("Hats","Samurai Hat",0)
	global.hat[28] = ini_read_real("Hats","Red Beanie Hat",0)
	global.hat[29] = ini_read_real("Hats","Yellow Beanie Hat",0)
	global.hat[30] = ini_read_real("Hats","Green Beanie Hat",0)
	global.hat[31] = ini_read_real("Hats","Blue Beanie Hat",0)
	global.hat[32] = ini_read_real("Hats","White Beanie Hat",0)
	global.hat[33] = ini_read_real("Hats","Pirate Hat",0)
	global.hat[34] = ini_read_real("Hats","Pink Bowtie Hat",0)
	global.hat[35] = ini_read_real("Hats","King's Hat",-1)
	global.hat[36] = ini_read_real("Hats","Hair",0)
	global.hat[37] = ini_read_real("Hats","Comrade Hat",0)
	global.hat[38] = ini_read_real("Hats","Viking Hat",0)
	global.hat[39] = ini_read_real("Hats","Cowboy Hat",0)
	global.hat[40] = ini_read_real("Hats","Red Sus Hat",0)
	global.hat[41] = ini_read_real("Hats","Yellow Sus Hat",0)
	global.hat[42] = ini_read_real("Hats","Green Sus Hat",0)
	global.hat[43] = ini_read_real("Hats","Blue Sus Hat",0)
	global.hat[44] = ini_read_real("Hats","White Sus Hat",0)
	global.hat[45] = ini_read_real("Hats","Flower Hat",0)
	global.hat[46] = ini_read_real("Hats","Propeller Hat",0)
	global.hat[47] = ini_read_real("Hats","Serbian Hat",1) //Flag
	global.hat[48] = ini_read_real("Hats","Rat Hat",0)
	global.hat[49] = ini_read_real("Hats","German Hat",0) //Flag
	global.hat[50] = ini_read_real("Hats","French Hat",0) //Flag
	global.hat[51] = ini_read_real("Hats","Italian Hat",0) //Flag
	global.hat[52] = ini_read_real("Hats","Spanish Hat",0) //Flag
	global.hat[53] = ini_read_real("Hats","Magyar Hat",0) //Flag
	global.hat[54] = ini_read_real("Hats","Bosnian Hat",0) //Flag
	global.hat[55] = ini_read_real("Hats","Chinese Hat",0) //Flag
	global.hat[56] = ini_read_real("Hats","Ukraine Hat",0) //Flag
	global.hat[57] = ini_read_real("Hats","Macedonian Hat",0) //Flag
	global.hat[58] = ini_read_real("Hats","Chicken Hat",0)
	global.hat[59] = ini_read_real("Hats","Czech Hat",0) //Flag
	global.hat[60] = ini_read_real("Hats","Russian Hat",0) //Flag
	global.hat[61] = ini_read_real("Hats","Devil Hat",0)
	global.hat[62] = ini_read_real("Hats","Turkish Hat",0) //Flag
	global.hat[63] = ini_read_real("Hats","Palestinian Hat",0) //Flag
	global.hat[64] = ini_read_real("Hats","Slovenian Hat",0) //Flag
	global.hat[65] = ini_read_real("Hats","Japanese Hat",0) //Flag
	global.hat[66] = ini_read_real("Hats","Romanian Hat",0) //Flag
	global.hat[67] = ini_read_real("Hats","Portuguese Hat",0) //Flag
	
	var totalflag = 0
	if global.hat[47] = 1 { totalflag += 1 }
	if global.hat[49] = 1 { totalflag += 1 }
	if global.hat[50] = 1 { totalflag += 1 }
	if global.hat[51] = 1 { totalflag += 1 }
	if global.hat[52] = 1 { totalflag += 1 }
	if global.hat[53] = 1 { totalflag += 1 }
	if global.hat[54] = 1 { totalflag += 1 }
	if global.hat[55] = 1 { totalflag += 1 }
	if global.hat[56] = 1 { totalflag += 1 }
	if global.hat[57] = 1 { totalflag += 1 }
	if global.hat[59] = 1 { totalflag += 1 }
	if global.hat[60] = 1 { totalflag += 1 }
	if global.hat[62] = 1 { totalflag += 1 }
	if global.hat[63] = 1 { totalflag += 1 }
	if global.hat[64] = 1 { totalflag += 1 }
	if global.hat[65] = 1 { totalflag += 1 }
	if global.hat[66] = 1 { totalflag += 1 }
	if global.hat[67] = 1 { totalflag += 1 }
	
	if totalflag >= 17 {
	if !steam_get_achievement("FLAG_GUY") { steam_set_achievement("FLAG_GUY") }
	}
	
	global.CUSTOMhat = ini_read_string("CustomHat","Custom Hat","")
	}
	else {
	}
	
	}

}