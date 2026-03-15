draw_set_font(global.deathfont)

draw_set_color(c_yellow)

if (((global.calendarmonth - global.calendarcurrentmonth) * 30.41666666666667) +8) - global.calendarcurrentday > 0 {
draw_text(160,329,loc("DAYS_TO_UNLOCK")+" " + string_format((((global.calendarmonth - global.calendarcurrentmonth) * 30.41666666666667) +8) - global.calendarcurrentday,0,0))
}
if (((global.calendarmonth - global.calendarcurrentmonth) * 30.41666666666667) +15) - global.calendarcurrentday > 0 {
draw_text(160,457,loc("DAYS_TO_UNLOCK")+" " + string_format((((global.calendarmonth - global.calendarcurrentmonth) * 30.41666666666667) +15) - global.calendarcurrentday,0,0))
}
if (((global.calendarmonth - global.calendarcurrentmonth) * 30.41666666666667) +22) - global.calendarcurrentday > 0 {
draw_text(160,585,loc("DAYS_TO_UNLOCK")+" " + string_format((((global.calendarmonth - global.calendarcurrentmonth) * 30.41666666666667) +22) - global.calendarcurrentday,0,0))
}
draw_set_color(c_white)
draw_text(52,201,loc("WEEK") + " " + string(1 + 4 * (global.calendarmonth-1)))
draw_text(52,329,loc("WEEK") + " " + string(2 + 4 * (global.calendarmonth-1)))
draw_text(52,457,loc("WEEK") +" " + string(3 + 4 * (global.calendarmonth-1)))
draw_text(52,585,loc("WEEK") + " " + string(4 + 4 * (global.calendarmonth-1)))