declarecustombutton()

/*if !os_is_network_connected() {
	global.calendarcurrentyear = current_year
	global.calendarcurrentmonth = current_month
	global.calendarcurrentday = current_day
}*/

switch(global.language) {
default: text = loc(632) break;
}
GooglePlayServices_Leaderboard_SubmitScore("CgkI36PRjvEQEAIQMQ",global.dailylevelhighstreak,"")
xscale = 0.7
yscale = 0.7
seed = ((global.calendarcurrentyear * global.calendarcurrentmonth) / global.calendarcurrentday)

date1 = date_create_datetime(global.dailylevelyear,global.dailylevelmonth,global.dailylevelday,0,0,0)
if os_is_network_connected() {
if global.gotcalendartime = 1 {
date2 = date_create_datetime(global.calendarcurrentyear,global.calendarcurrentmonth,global.calendarcurrentday,0,0,0)
} else { date2 = date_create_datetime(current_year,current_month,current_day,0,0,0) }
} else { date2 = date_create_datetime(current_year,current_month,current_day,0,0,0) }
date3 = date_create_datetime(2022,4,17,0,0,0)

diff = date_day_span(date1, date2);
diff2 = date_day_span(date3,date2)

if diff = 0 { locked = 1 }
if diff = 1 { locked = 0 }
if diff >= 14 { locked = 0
	global.dailylevelstreak = 0
	steam_upload_score_ext("Current Daily Level Streak", 0,true);
	}

image_speed = 0
image_index = 0
