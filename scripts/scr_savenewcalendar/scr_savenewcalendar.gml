function scr_savenewcalendar() {
	if global.cheats = 0 {
		
	var directory = directory_set("/Save Files//Calendar/")

	var diff = "Easy"
		switch(global.calendardifficulty) {
	case(1): diff = "Easy" break;
	case(2): diff = "Normal" break;
	case(3): diff = "Hard" break;
	}
	if (file_exists(directory + "NewCalendar" + diff + string(global.calendarcurrentweek) + ".sav")) file_delete(directory + "NewCalendar" + diff + string(global.calendarcurrentweek) + ".sav");
	ini_open(directory + "NewCalendar" +diff +  string(global.calendarcurrentweek) + ".sav");
	
	ini_write_real(diff,"L1",global.newcalendarlevel1);
	ini_write_real(diff,"L2",global.newcalendarlevel2);
	ini_write_real(diff,"L3",global.newcalendarlevel3);
	ini_write_real(diff,"L4",global.newcalendarlevel4);
	ini_write_real(diff,"L5",global.newcalendarlevel5);
	ini_write_real(diff,"L6",global.newcalendarlevel6);
	ini_write_real(diff,"L7",global.newcalendarlevel7);
	ini_write_real(diff,"Rewarded",global.newcalendarrewarded);
	ini_write_real(diff,"Seed",global.newcalendarseed);
	ini_write_real(diff,"Reward",global.newcalendarreward)
	ini_write_real(diff,"Week",global.calendarcurrentweek)
	ini_write_real(diff,"Month",global.calendarcurrentmonth)
	ini_write_real(diff,"Year",global.calendarcurrentyear)
	ini_close();
}}