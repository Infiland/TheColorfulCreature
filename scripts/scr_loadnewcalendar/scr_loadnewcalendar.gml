function scr_loadnewcalendar() {
if global.cheats = 0 {
	var directory = working_directory + "/Save Files//Calendar/"
	var diff = "Easy"
	var week = 1
	var month = 1
	var year = 1
	switch(global.calendardifficulty) {
	case(1): diff = "Easy" break;
	case(2): diff = "Normal" break;
	case(3): diff = "Hard" break;
	}
		if (file_exists(directory + "NewCalendar"+diff + +string(global.calendarcurrentweek) +".sav")) {
	ini_open(directory + "NewCalendar"+diff + string(global.calendarcurrentweek) +".sav");
	global.newcalendarlevel1 = ini_read_real(diff,"L1",0);
	global.newcalendarlevel2 = ini_read_real(diff,"L2",0);
	global.newcalendarlevel3 = ini_read_real(diff,"L3",0);
	global.newcalendarlevel4 = ini_read_real(diff,"L4",0);
	global.newcalendarlevel5 = ini_read_real(diff,"L5",0);
	global.newcalendarlevel6 = ini_read_real(diff,"L6",0);
	global.newcalendarlevel7 = ini_read_real(diff,"L7",0);
	global.newcalendarrewarded = ini_read_real(diff,"Rewarded",0);
	global.newcalendarreward = ini_read_real(diff,"Reward",0);
	global.newcalendarseed = ini_read_real(diff,"Seed",0);
	week = ini_read_real(diff,"Week",0)
	month = ini_read_real(diff,"Month",0)
    year = ini_read_real(diff,"Year",0)
	}
	else {
	}
	if global.calendarcurrentweek = 5 {
		file_delete(directory + "NewCalendar"+diff+"1.sav")
		file_delete(directory + "NewCalendar"+diff+"2.sav")
		file_delete(directory + "NewCalendar"+diff+"3.sav")
		file_delete(directory + "NewCalendar"+diff+"4.sav")
	}
	if global.calendarcurrentweek = 4 {
		file_delete(directory + "NewCalendar"+diff+"1.sav")
		file_delete(directory + "NewCalendar"+diff+"2.sav")
		file_delete(directory + "NewCalendar"+diff+"3.sav")
	}
	if global.calendarcurrentweek = 3 {
		file_delete(directory + "NewCalendar"+diff+"1.sav")
		file_delete(directory + "NewCalendar"+diff+"2.sav")
		file_delete(directory + "NewCalendar"+diff+"4.sav")
	}
	if global.calendarcurrentweek = 2 {
		file_delete(directory + "NewCalendar"+diff+"1.sav")
		file_delete(directory + "NewCalendar"+diff+"3.sav")
		file_delete(directory + "NewCalendar"+diff+"4.sav")
	}
	if global.calendarcurrentweek = 1 {
		file_delete(directory + "NewCalendar"+diff+"2.sav")
		file_delete(directory + "NewCalendar"+diff+"3.sav")
		file_delete(directory + "NewCalendar"+diff+"4.sav")
	}
	file_delete(directory + "NewCalendar"+diff+".sav")
	file_delete(directory + "NewCalendar"+diff+".sav")
	file_delete(directory + "NewCalendar"+diff+".sav")
	/*if week != global.calendarcurrentweek { file_delete(directory + "NewCalendar"+diff+".sav")	}
	if month != global.calendarcurrentmonth { file_delete(directory + "NewCalendar"+diff+".sav")	}
	if year != global.calendarcurrentyear { file_delete(directory + "NewCalendar"+diff+".sav")	}*/
}
}