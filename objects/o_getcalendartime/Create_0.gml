global.calendarcurrentday = 2
global.calendarcurrentweek = 1
global.calendarcurrentmonth = 4
global.calendarcurrentyear = 2022

global.gotcalendartime = 0

if (TCC_GAMEPLAY_QA || TCC_STEAM_ANDROID) {
    // QA gets a fixed date; the offline Steam APK uses the device calendar.
    var _date = TCC_GAMEPLAY_QA ? date_create_datetime(2026, 1, 1, 12, 0, 0) : date_current_datetime();
    global.calendarcurrentday = date_get_day(_date);
    global.calendarcurrentmonth = date_get_month(_date);
    global.calendarcurrentyear = date_get_year(_date);
    global.calendarcurrentweek = ceil(global.calendarcurrentday / 7);
    global.gotcalendartime = 1;
    get = -1;
    exit;
}

//Request current time from this server
get = http_get("https://www.timeapi.io/api/Time/current/zone?timeZone=Europe/Amsterdam")
alarm[0] = 1000 * (60 / global.maxfps) //Refresh
