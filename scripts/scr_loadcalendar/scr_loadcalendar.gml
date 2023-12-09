function scr_loadcalendar() {
if global.cheats = 0 {
	var directory = working_directory + "/Save Files//Calendar/"
	if (file_exists(directory + "Calendar.sav")) {
	ini_open(directory + "Calendar.sav");
	global.calendar2022unlock = ini_read_real("Calendar","2022",0);
	var week = ini_read_real("Calendar","Week",0)
	}
	else {
	}
	}

}
