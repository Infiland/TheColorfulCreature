//Request current time from this server
get = http_get("https://www.timeapi.io/api/Time/current/zone?timeZone=Europe/Amsterdam")

global.calendarcurrentweek = ceil(global.calendarcurrentday/7)