
function scr_checkcalendarrewardsinmenu(){
var monthtext
switch(global.calendarmonth) {
case(1): monthtext = "/January//" break;
case(2): monthtext = "/February//" break;
case(3): monthtext = "/March//" break;
case(4): monthtext = "/April//" break;
case(5): monthtext = "/May//" break;
case(6): monthtext = "/June//" break;
case(7): monthtext = "/July//" break;
case(8): monthtext = "/August//" break;
case(9): monthtext = "/September//" break;
case(10): monthtext = "/October//" break;
case(11): monthtext = "/November//" break;
case(12): monthtext = "/December//" break;
}

var directory = game_save_id + "/Save Files//Calendar//" + string(global.calendaryear) + "/" + monthtext

if global.cheats = 0 {
if (file_exists(directory + "Cal" + string(global.calendaryear) + "_" + string(global.calendarmonth) + "_" + string(1) + ".sav")) {
	ini_open(directory + "Cal" + string(global.calendaryear) + "_" + string(global.calendarmonth) + "_" + string(1) + ".sav")
	rewarded1 = ini_read_real("Day","Rewarded?",0);
}
if (file_exists(directory + "Cal" + string(global.calendaryear) + "_" + string(global.calendarmonth) + "_" + string(2) + ".sav")) {
	ini_open(directory + "Cal" + string(global.calendaryear) + "_" + string(global.calendarmonth) + "_" + string(2) + ".sav")
	rewarded2 = ini_read_real("Day","Rewarded?",0);
}
if (file_exists(directory + "Cal" + string(global.calendaryear) + "_" + string(global.calendarmonth) + "_" + string(3) + ".sav")) {
	ini_open(directory + "Cal" + string(global.calendaryear) + "_" + string(global.calendarmonth) + "_" + string(3) + ".sav")
	rewarded3 = ini_read_real("Day","Rewarded?",0);
}
if (file_exists(directory + "Cal" + string(global.calendaryear) + "_" + string(global.calendarmonth) + "_" + string(4) + ".sav")) {
	ini_open(directory + "Cal" + string(global.calendaryear) + "_" + string(global.calendarmonth) + "_" + string(4) + ".sav")
	rewarded4 = ini_read_real("Day","Rewarded?",0);
}





}
}