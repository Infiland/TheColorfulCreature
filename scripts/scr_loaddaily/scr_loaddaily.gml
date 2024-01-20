function scr_loaddaily() {
	if steam_get_app_id() != 1749610 {
		
	var directory = directory_set("//Save Files/")
	
	if (file_exists(directory + "Daily.sav")) {
	ini_open(directory + "Daily.sav")
	global.dailylevelstreak = ini_read_real("Daily","Streak",0);
	global.dailylevelhighstreak = ini_read_real("Daily","Highest Streak",0);
	global.dailylevelday = ini_read_real("Daily","Day",1);
	global.dailylevelmonth = ini_read_real("Daily","Month",1);
	global.dailylevelyear = ini_read_real("Daily","Year",2021);
	}
	else {
	}
	}

}