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
	ini_write_real("Skins","Normal Skin",global.skin001);
	ini_write_real("Skins","Kaizo Skin",global.skin002);
	ini_write_real("Skins","Mad Skin",global.skin003);
	ini_write_real("Skins","Blind Skin",global.skin004);
	ini_write_real("Skins","Sad Skin",global.skin005);
	ini_write_real("Skins","Block Skin",global.skin006);
	ini_write_real("Skins","HD Skin",global.skin007);
	ini_write_real("Skins","Rewarded Skin",global.skin008);
	ini_write_real("Skins","Angry Skin",global.skin009);
	ini_write_real("Skins","Cool Skin",global.skin010);
	ini_write_real("Skins","The Dark Knight Skin",global.skin011);
	ini_write_real("Skins","Rich Skin",global.skin012);
	ini_write_real("Skins","Gold Skin",global.skin013);
	ini_write_real("Skins","Frozen Skin",global.skin014);
	ini_write_real("Skins","Kinda Dead Skin",global.skin015);
	ini_write_real("Skins","Corona Skin",global.skin016);
	ini_write_real("Skins","Canadian Skin",global.skin017);
	ini_write_real("Skins","Hazardous Skin",global.skin018);
	ini_write_real("Skins","Baby Skin",global.skin019);
	ini_write_real("Skins","Hexagon Skin",global.skin020);
	ini_write_real("Skins","Texudo Skin",global.skin021);
	ini_write_real("Skins","Very Animated Skin",global.skin022);
	ini_write_real("Skins","Underwater Skin",global.skin023);
	ini_write_real("Skins","forsenE",global.skin024);
	ini_write_real("Skins","Red Ball",global.skin025);
	ini_write_real("Skins","Bomber Skin",global.skin026);
	ini_write_real("Skins","Hitbox Skin",global.skin027);
	ini_write_real("Skins","Metallic Skin",global.skin028);
	ini_write_real("Skins","Monocle Skin",global.skin029);
	ini_write_real("Skins","Japanese Skin",global.skin030);
	ini_write_real("Skins","Googly Skin",global.skin031);
	ini_write_real("Skins","Upside-Down Skin",global.skin032);
	ini_write_real("Skins","Spiral Skin",global.skin033);
	ini_write_real("Skins","Heart Skin",global.skin034);
	ini_write_real("Skins","Clock Skin",global.skin035);
	ini_write_real("Skins","Invisible Skin",global.skin036);
	ini_write_real("Skins","Spike Skin",global.skin037);
	ini_write_real("Skins","Arrow Skin",global.skin038);
	ini_write_real("Skins","Split Skin",global.skin039);
	ini_write_real("Skins","Pirate Skin",global.skin040);
	ini_write_real("Skins","Sci-fi Skin",global.skin041);
	ini_write_real("Skins","Gordon Skin",global.skin042);
	ini_write_real("Skins","Fancy Skin",global.skin043);
	ini_write_real("Skins","Steam Skin",global.skin044);
	ini_write_real("Skins","Breakable Skin",global.skin045);
	ini_write_real("Skins","Smiley Skin",global.skin046);
	ini_write_real("Skins","Maid Skin",global.skin047);
	ini_write_real("Skins","Burning Skin",global.skin048);
	ini_write_real("Skins","Skibidi Skin",global.skin049);
	ini_write_real("Skins","Kratos Skin",global.skin050);
	ini_close();

	}
}