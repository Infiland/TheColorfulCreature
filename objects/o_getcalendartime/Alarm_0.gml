if (!timing_is_tick()) exit;
//Request current time from this server
if (TCC_GAMEPLAY_QA || TCC_STEAM_ANDROID) exit;
get = http_get("https://www.timeapi.io/api/Time/current/zone?timeZone=Europe/Amsterdam")

global.calendarcurrentweek = ceil(global.calendarcurrentday/7)
