global.calendarcurrentday = 2
global.calendarcurrentweek = 1
global.calendarcurrentmonth = 4
global.calendarcurrentyear = 2022

global.gotcalendartime = 0

get = http_get("https://www.timeapi.io/api/Time/current/zone?timeZone=Europe/Amsterdam")
alarm[0] = 1000 * (60 / global.maxfps)