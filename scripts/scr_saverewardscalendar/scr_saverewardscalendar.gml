function scr_saverewardscalendar(){
if global.cheats = 0 {
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
if (file_exists(directory + "Cal" + string(global.calendaryear) + "_" + string(global.calendarmonth) + "_" + string(global.calendarweek) + ".sav")) file_delete(directory + "Cal" + string(global.calendaryear) + "_" + string(global.calendarmonth) + "_" + string(global.calendarweek) + ".sav");
ini_open(directory + "Cal" + string(global.calendaryear) + "_" + string(global.calendarmonth) + "_" + string(global.calendarweek) + ".sav");

ini_write_real("Day","1",global.calendarday1required);
ini_write_real("Day","2",global.calendarday2required);
ini_write_real("Day","3",global.calendarday3required);
ini_write_real("Day","4",global.calendarday4required);
ini_write_real("Day","5",global.calendarday5required);
ini_write_real("Day","6",global.calendarday6required);
ini_write_real("Day","7",global.calendarday7required);
ini_write_real("Day","Rewarded?",global.calendarrewarded);

}
}