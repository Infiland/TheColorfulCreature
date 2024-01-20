function scr_savecalendar() {
if global.cheats = 0 {	
	var directory = directory_set("/Save Files//Calendar/")
	if (file_exists(directory + "Calendar.sav")) file_delete(directory + "Calendar.sav");
	ini_open(directory + "Calendar.sav");
	
	ini_write_real("Calendar","2022",global.calendar2022unlock);
	ini_write_real("Calendar","Week",global.calendarcurrentweek)
	ini_write_real("Calendar","Month",global.calendarcurrentmonth)
	ini_write_real("Calendar","Year",global.calendarcurrentyear)
	ini_write_real("Calendar","Seed",global.newcalendarseed);
	ini_write_real("Calendar","Reward",global.newcalendarreward)
	ini_close();
	}

}