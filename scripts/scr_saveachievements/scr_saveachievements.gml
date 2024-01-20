function scr_saveachievements() {
if global.cheats = 0 {
	
	var directory = directory_set("//Save Files/")
	
	if (file_exists(directory + "Achievements.sav")) file_delete(directory + "Achievements.sav");
	ini_open(directory + "Achievements.sav");
	ini_write_real("Achievements","Is Grayscale",global.isgrayscale);
	ini_write_real("Achievements","Is Invisible",global.isinvisible);
	ini_write_real("Achievements","Is Reversed",global.isreversed);
	ini_close();
	}

}