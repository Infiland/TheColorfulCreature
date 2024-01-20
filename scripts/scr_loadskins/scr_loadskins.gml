function scr_loadskins() {
	if global.cheats = 0 {
		
	var directory = game_save_id
	if global.moddedGameDir != "" { directory += "MODS//" + string(global.moddedGameDir) }
	directory += "//Save Files/"
	
	if (file_exists(directory + "Skins.sav")) {
	ini_open(directory + "Skins.sav");
	global.world1 = ini_read_real("Skins","World 1",0)
	global.world2 = ini_read_real("Skins","World 2",0)
	global.world3 = ini_read_real("Skins","World 3",0)
	global.world4 = ini_read_real("Skins","World 4",0)
	global.world5 = ini_read_real("Skins","World 5",0)
	global.skinselected = ini_read_real("Skins","Selected Skin",0)
	global.skin001 = ini_read_real("Skins","Normal Skin",1);
	global.skin002 = ini_read_real("Skins","Kaizo Skin",0);
	global.skin003 = ini_read_real("Skins","Mad Skin",0);
	global.skin004 = ini_read_real("Skins","Blind Skin",0);
	global.skin005 = ini_read_real("Skins","Sad Skin",0);
	global.skin006 = ini_read_real("Skins","Block Skin",0);
	global.skin007 = ini_read_real("Skins","HD Skin",0);
	global.skin008 = ini_read_real("Skins","Rewarded Skin",0);
	global.skin009 = ini_read_real("Skins","Angry Skin",0);
	global.skin010 = ini_read_real("Skins","Cool Skin",0);
	global.skin011 = ini_read_real("Skins","The Dark Knight Skin",0);
	global.skin012 = ini_read_real("Skins","Rich Skin",0);
	global.skin013 = ini_read_real("Skins","Gold Skin",0);
	global.skin014 = ini_read_real("Skins","Frozen Skin",0);
	global.skin015 = ini_read_real("Skins","Kinda Dead Skin",0);
	global.skin016 = ini_read_real("Skins","Corona Skin",0);
	global.skin017 = ini_read_real("Skins","Canadian Skin",0);
	global.skin018 = ini_read_real("Skins","Hazardous Skin",0);
	global.skin019 = ini_read_real("Skins","Baby Skin",0);
	global.skin020 = ini_read_real("Skins","Hexagon Skin",0);
	global.skin021 = ini_read_real("Skins","Texudo Skin",0);
	global.skin022 = ini_read_real("Skins","Very Animated Skin",0);
	global.skin023 = ini_read_real("Skins","Underwater Skin",0);
	global.skin024 = ini_read_real("Skins","forsenE",0);
	global.skin025 = ini_read_real("Skins","Red Ball",0);
	global.skin026 = ini_read_real("Skins","Bomber Skin",0);
	global.skin027 = ini_read_real("Skins","Hitbox Skin",0);
	global.skin028 = ini_read_real("Skins","Metallic Skin",0);
	global.skin029 = ini_read_real("Skins","Monocle Skin",0);
	global.skin030 = ini_read_real("Skins","Japanese Skin",0);
	global.skin031 = ini_read_real("Skins","Googly Skin",0);
	global.skin032 = ini_read_real("Skins","Upside-Down Skin",0);
	global.skin033 = ini_read_real("Skins","Spiral Skin",0);
	global.skin034 = ini_read_real("Skins","Heart Skin",0);
	global.skin035 = ini_read_real("Skins","Clock Skin",0);
	global.skin036 = ini_read_real("Skins","Invisible Skin",0);
	global.skin037 = ini_read_real("Skins","Spike Skin",0);
	global.skin038 = ini_read_real("Skins","Arrow Skin",0);
	global.skin039 = ini_read_real("Skins","Split Skin",0);
	global.skin040 = ini_read_real("Skins","Pirate Skin",0);
	global.skin041 = ini_read_real("Skins","Sci-fi Skin",0);
	global.skin042 = ini_read_real("Skins","Gordon Skin",0);
	global.skin043 = ini_read_real("Skins","Fancy Skin",0);
	global.skin044 = ini_read_real("Skins","Steam Skin",0);
	global.skin045 = ini_read_real("Skins","Breakable Skin",0);
	global.skin046 = ini_read_real("Skins","Smiley Skin",0);
	global.skin047 = ini_read_real("Skins","Maid Skin",0);
	global.skin048 = ini_read_real("Skins","Burning Skin",0);
	}
	else {
	}

}
}
