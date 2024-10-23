function scr_saveskins() {
	
	if global.cheats = 0 {
	
	var directory = directory_set("//Save Files/")
	
	if (file_exists(directory + "Skins.sav")) file_delete(directory + "Skins.sav");
	ini_open(directory + "Skins.sav");
	//Skins
	ini_write_real("Skins","World 1",global.world1);
	ini_write_real("Skins","World 2",global.world2);
	ini_write_real("Skins","World 3",global.world3);
	ini_write_real("Skins","World 4",global.world4);
	ini_write_real("Skins","World 5",global.world5);
	ini_write_real("Skins","Selected Skin",global.skinselected);
	ini_write_real("Skins","Skin Name Object Selected",global.skinnameobjectselected)
	ini_write_real("Skins","Normal Skin",global.skin[1]);
	ini_write_real("Skins","Kaizo Skin",global.skin[2]);
	ini_write_real("Skins","Mad Skin",global.skin[3]);
	ini_write_real("Skins","Blind Skin",global.skin[4]);
	ini_write_real("Skins","Sad Skin",global.skin[5]);
	ini_write_real("Skins","Block Skin",global.skin[6]);
	ini_write_real("Skins","HD Skin",global.skin[7]);
	ini_write_real("Skins","Rewarded Skin",global.skin[8]);
	ini_write_real("Skins","Angry Skin",global.skin[9]);
	ini_write_real("Skins","Cool Skin",global.skin[10]);
	ini_write_real("Skins","The Dark Knight Skin",global.skin[11]);
	ini_write_real("Skins","Rich Skin",global.skin[12]);
	ini_write_real("Skins","Gold Skin",global.skin[13]);
	ini_write_real("Skins","Frozen Skin",global.skin[14]);
	ini_write_real("Skins","Kinda Dead Skin",global.skin[15]);
	ini_write_real("Skins","Corona Skin",global.skin[16]);
	ini_write_real("Skins","Canadian Skin",global.skin[17]);
	ini_write_real("Skins","Hazardous Skin",global.skin[18]);
	ini_write_real("Skins","Baby Skin",global.skin[19]);
	ini_write_real("Skins","Hexagon Skin",global.skin[20]);
	ini_write_real("Skins","Texudo Skin",global.skin[21]);
	ini_write_real("Skins","Very Animated Skin",global.skin[22]);
	ini_write_real("Skins","Underwater Skin",global.skin[23]);
	ini_write_real("Skins","forsenE",global.skin[24]);
	ini_write_real("Skins","Red Ball",global.skin[25]);
	ini_write_real("Skins","Bomber Skin",global.skin[26]);
	ini_write_real("Skins","Hitbox Skin",global.skin[27]);
	ini_write_real("Skins","Metallic Skin",global.skin[28]);
	ini_write_real("Skins","Monocle Skin",global.skin[29]);
	ini_write_real("Skins","Japanese Skin",global.skin[30]);
	ini_write_real("Skins","Googly Skin",global.skin[31]);
	ini_write_real("Skins","Upside-Down Skin",global.skin[32]);
	ini_write_real("Skins","Spiral Skin",global.skin[33]);
	ini_write_real("Skins","Heart Skin",global.skin[34]);
	ini_write_real("Skins","Clock Skin",global.skin[35]);
	ini_write_real("Skins","Invisible Skin",global.skin[36]);
	ini_write_real("Skins","Spike Skin",global.skin[37]);
	ini_write_real("Skins","Arrow Skin",global.skin[38]);
	ini_write_real("Skins","Split Skin",global.skin[39]);
	ini_write_real("Skins","Pirate Skin",global.skin[40]);
	ini_write_real("Skins","Sci-fi Skin",global.skin[41]);
	ini_write_real("Skins","Gordon Skin",global.skin[42]);
	ini_write_real("Skins","Fancy Skin",global.skin[43]);
	ini_write_real("Skins","Steam Skin",global.skin[44]);
	ini_write_real("Skins","Breakable Skin",global.skin[45]);
	ini_write_real("Skins","Smiley Skin",global.skin[46]);
	ini_write_real("Skins","Maid Skin",global.skin[47]);
	ini_write_real("Skins","Burning Skin",global.skin[48]);
	ini_write_real("Skins","Toilet Skin",global.skin[49]);
	ini_write_real("Skins","Kratos Skin",global.skin[50]);
	ini_close();

	}
}