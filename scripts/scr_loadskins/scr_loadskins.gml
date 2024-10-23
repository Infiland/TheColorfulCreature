function scr_loadskins() {
	if global.cheats = 0 {
		
	var directory = directory_set("//Save Files/")
	
	if (file_exists(directory + "Skins.sav")) {
	ini_open(directory + "Skins.sav");
	global.world1 = ini_read_real("Skins","World 1",0)
	global.world2 = ini_read_real("Skins","World 2",0)
	global.world3 = ini_read_real("Skins","World 3",0)
	global.world4 = ini_read_real("Skins","World 4",0)
	global.world5 = ini_read_real("Skins","World 5",0)
	global.skinselected = ini_read_real("Skins","Selected Skin",0)
	global.skinnameobjectselected = ini_read_real("Skins","Skin Name Object Selected",o_normalskinbutton)
	global.skin[1] = ini_read_real("Skins","Normal Skin",1);
	global.skin[2] = ini_read_real("Skins","Kaizo Skin",0);
	global.skin[3] = ini_read_real("Skins","Mad Skin",0);
	global.skin[4] = ini_read_real("Skins","Blind Skin",0);
	global.skin[5] = ini_read_real("Skins","Sad Skin",0);
	global.skin[6] = ini_read_real("Skins","Block Skin",0);
	global.skin[7] = ini_read_real("Skins","HD Skin",0);
	global.skin[8] = ini_read_real("Skins","Rewarded Skin",0);
	global.skin[9] = ini_read_real("Skins","Angry Skin",0);
	global.skin[10] = ini_read_real("Skins","Cool Skin",0);
	global.skin[11] = ini_read_real("Skins","The Dark Knight Skin",0);
	global.skin[12] = ini_read_real("Skins","Rich Skin",0);
	global.skin[13] = ini_read_real("Skins","Gold Skin",0);
	global.skin[14] = ini_read_real("Skins","Frozen Skin",0);
	global.skin[15] = ini_read_real("Skins","Kinda Dead Skin",0);
	global.skin[16] = ini_read_real("Skins","Corona Skin",0);
	global.skin[17] = ini_read_real("Skins","Canadian Skin",0);
	global.skin[18] = ini_read_real("Skins","Hazardous Skin",0);
	global.skin[19] = ini_read_real("Skins","Baby Skin",0);
	global.skin[20] = ini_read_real("Skins","Hexagon Skin",0);
	global.skin[21] = ini_read_real("Skins","Texudo Skin",0);
	global.skin[22] = ini_read_real("Skins","Very Animated Skin",0);
	global.skin[23] = ini_read_real("Skins","Underwater Skin",0);
	global.skin[24] = ini_read_real("Skins","forsenE",0);
	global.skin[25] = ini_read_real("Skins","Red Ball",0);
	global.skin[26] = ini_read_real("Skins","Bomber Skin",0);
	global.skin[27] = ini_read_real("Skins","Hitbox Skin",0);
	global.skin[28] = ini_read_real("Skins","Metallic Skin",0);
	global.skin[29] = ini_read_real("Skins","Monocle Skin",0);
	global.skin[30] = ini_read_real("Skins","Japanese Skin",0);
	global.skin[31] = ini_read_real("Skins","Googly Skin",0);
	global.skin[32] = ini_read_real("Skins","Upside-Down Skin",0);
	global.skin[33] = ini_read_real("Skins","Spiral Skin",0);
	global.skin[34] = ini_read_real("Skins","Heart Skin",0);
	global.skin[35] = ini_read_real("Skins","Clock Skin",0);
	global.skin[36] = ini_read_real("Skins","Invisible Skin",0);
	global.skin[37] = ini_read_real("Skins","Spike Skin",0);
	global.skin[38] = ini_read_real("Skins","Arrow Skin",0);
	global.skin[39] = ini_read_real("Skins","Split Skin",0);
	global.skin[40] = ini_read_real("Skins","Pirate Skin",0);
	global.skin[41] = ini_read_real("Skins","Sci-fi Skin",0);
	global.skin[42] = ini_read_real("Skins","Gordon Skin",0);
	global.skin[43] = ini_read_real("Skins","Fancy Skin",0);
	global.skin[44] = ini_read_real("Skins","Steam Skin",0);
	global.skin[45] = ini_read_real("Skins","Breakable Skin",0);
	global.skin[46] = ini_read_real("Skins","Smiley Skin",0);
	global.skin[47] = ini_read_real("Skins","Maid Skin",0);
	global.skin[48] = ini_read_real("Skins","Burning Skin",0);
	global.skin[49] = ini_read_real("Skins","Toilet Skin",0);
	global.skin[50] = ini_read_real("Skins","Kratos Skin",0);
	}
	else {
	}

}
}
