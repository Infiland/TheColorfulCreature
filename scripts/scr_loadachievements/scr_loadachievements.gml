function scr_loadachievements() {
if global.cheats = 0 {
	
	var directory = game_save_id
	if global.moddedGameDir != "" { directory += "MODS//" + string(global.moddedGameDir) }
	directory += "//Save Files/"
	
	if (file_exists(directory + "Achievements.sav")) {
	ini_open(directory + "Achievements.sav");
	global.isgrayscale = ini_read_real("Achievements","Is Grayscale",false);
	global.isinvisible = ini_read_real("Achievements","Is Invisible",false);
	global.isreversed = ini_read_real("Achievements","Is Reversed",false);
	}
	else {
	}
	}

}
