function scr_savedaily() {
	
	var directory = game_save_id
	if global.moddedGameDir != "" { directory += "MODS//" + string(global.moddedGameDir) }
	directory += "//Save Files/"
	
	if (file_exists(directory + "Daily.sav")) file_delete(directory + "Daily.sav");
	ini_open(directory + "Daily.sav");
	ini_write_real("Daily","Streak",global.dailylevelstreak);
	ini_write_real("Daily","Highest Streak",global.dailylevelhighstreak);
	ini_write_real("Daily","Day",global.dailylevelday);
	ini_write_real("Daily","Month",global.dailylevelmonth);
	ini_write_real("Daily","Year",global.dailylevelyear);
	ini_close();
}
