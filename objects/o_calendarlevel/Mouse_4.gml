if locked = 1 { exit }
var level = asset_get_index("r_c" + string(global.calendaryear) + "lvl" + string(day + (28 * (global.calendarmonth-1))))
global.calendar = 1
calendarcheckmusic()
if room_exists(level) {
room_goto(level)
global.calendarweek = week
global.calendarday = day
scr_loadrewardscalendar()

loadhud()
}
