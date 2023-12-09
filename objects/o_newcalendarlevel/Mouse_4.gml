var level = asset_get_index("r_c2022lvl" + string(variable_global_get(("calendarday" + string(day)))))

global.calendar = 2
random_set_seed(global.newcalendarseed)
global.chooserandommusic = irandom_range(1,29)
randomsong()
room_goto(level)
rousr_dissonance_set_details("Playing Calendar")
loadhud()