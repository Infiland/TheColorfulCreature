//Screenshots shortcut

var second = date_get_second(date_current_datetime());
var minute = date_get_minute(date_current_datetime());
var hour = date_get_hour(date_current_datetime());
var day = date_get_day(date_current_datetime());
var month = date_get_month(date_current_datetime());
var year = date_get_year(date_current_datetime());

screen_save(game_save_id + "/Screenshots/" + string(year)+"-"+string(month)+"-"+string(day)+"-"+string(hour)+"-"+string(minute)+"-"+string(second) + ".png")