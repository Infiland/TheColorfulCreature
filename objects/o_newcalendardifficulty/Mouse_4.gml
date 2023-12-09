scr_savenewcalendar()
global.calendardifficulty = difficulty

	/*var directory = working_directory + "/Save Files//Calendar/"
	if (file_exists(directory + "NewCalendar.sav")) {
	ini_open(directory + "NewCalendar.sav");
	global.calendarcurrentweek = ini_read_real("Calendar","Week",0);
	}*/

scr_loadnewcalendar()
with (o_newcalendarlevel) {
event_user(0)
}