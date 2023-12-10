function scr_loadrewardscalendarlocal(){
var month
switch(global.calendarmonth) {
case(1): month = "/January//" break;
case(2): month = "/February//" break;
case(3): month = "/March//" break;
case(4): month = "/April//" break;
case(5): month = "/May//" break;
case(6): month = "/June//" break;
case(7): month = "/July//" break;
case(8): month = "/August//" break;
case(9): month = "/September//" break;
case(10): month = "/October//" break;
case(11): month = "/November//" break;
case(12): month = "/December//" break;
}

var directory = game_save_id + "/Save Files//Calendar//" + string(global.calendaryear) + "/" + month

if global.cheats = 0 {
	
	if (file_exists(directory + "Cal" + string(global.calendaryear) + "_" + string(global.calendarmonth) + "_" + string(week) + ".sav")) {
	ini_open(directory + "Cal" + string(global.calendaryear) + "_" + string(global.calendarmonth) + "_" + string(week) + ".sav");
	day1 = ini_read_real("Day","1",0);
	day2 = ini_read_real("Day","2",0);
	day3 = ini_read_real("Day","3",0);
	day4 = ini_read_real("Day","4",0);
	day5 = ini_read_real("Day","5",0);
	day6 = ini_read_real("Day","6",0);
	day7 = ini_read_real("Day","7",0);
	rewarded = ini_read_real("Day","Rewarded?",0);
	}
	else {
	}
	
	}
}