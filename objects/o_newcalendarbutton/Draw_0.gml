scr_custombutton()
draw_set_font(global.deathfont)

if os_is_network_connected() {
/*
if global.calendarcurrentyear != 2022 {
locked = 0
text = "Calendar"
}
if global.calendarcurrentday != 2 {
locked = 0
text = "Calendar"
}
if global.calendarcurrentmonth != 4 {
locked = 0
text = "Calendar"
}*/
if global.calendarcurrentweek < 5 {
if global.gotcalendartime = 1 {
locked = 0
text = "Calendar"	
}} else {
lockedtext = "Wait a few days"
locksprite = 0
}
}