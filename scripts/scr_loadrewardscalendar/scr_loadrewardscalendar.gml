function scr_loadrewardscalendar(){
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
	
	if (file_exists(directory + "Cal" + string(global.calendaryear) + "_" + string(global.calendarmonth) + "_" + string(global.calendarweek) + ".sav")) {
	ini_open(directory + "Cal" + string(global.calendaryear) + "_" + string(global.calendarmonth) + "_" + string(global.calendarweek) + ".sav");
	global.calendarday1required = ini_read_real("Day","1",0);
	global.calendarday2required = ini_read_real("Day","2",0);
	global.calendarday3required = ini_read_real("Day","3",0);
	global.calendarday4required = ini_read_real("Day","4",0);
	global.calendarday5required = ini_read_real("Day","5",0);
	global.calendarday6required = ini_read_real("Day","6",0);
	global.calendarday7required = ini_read_real("Day","7",0);
	global.calendarrewarded = ini_read_real("Day","Rewarded?",0);
	}
	else {
	}
	
	}
}