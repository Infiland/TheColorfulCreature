function scr_checkcalendarrewards(month,week){

var monthtext
switch(month) {
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
if (file_exists(directory + "Cal" + string(global.calendaryear) + "_" + string(global.calendarmonth) + "_" + string(week) + ".sav")) {
	ini_open(directory + "Cal" + string(global.calendaryear) + "_" + string(global.calendarmonth) + "_" + string(week) + ".sav")
	global.calendarrewarded = ini_read_real("Day","Rewarded?",0);
}

if global.calendarday1required = 1 {
if global.calendarday2required = 1 {
if global.calendarday3required = 1 {
if global.calendarday4required = 1 {
if global.calendarday5required = 1 {
if global.calendarday6required = 1 {
if global.calendarday7required = 1 {
if global.calendarrewarded = 0 {
scr_getrewardcalendar(month,week)
global.calendarrewarded = 1
if (file_exists(directory + "Cal" + string(global.calendaryear) + "_" + string(month) + "_" + string(week) + ".sav")) file_delete(directory + "Cal" + string(global.calendaryear) + "_" + string(month) + "_" + string(week) + ".sav");
ini_open(directory + "Cal" + string(global.calendaryear) + "_" + string(month) + "_" + string(week) + ".sav");
ini_write_real("Day","Rewarded?",global.calendarrewarded);
}}}}}}}}


}}