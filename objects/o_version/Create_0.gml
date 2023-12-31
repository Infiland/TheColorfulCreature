/// @description Game's Version
randomize()
global._ef_water.cutoff = 20000
global._ef_gain.gain = 1
r_str = "0"

get = http_get("https://api.steampowered.com/ISteamUserStats/GetNumberOfCurrentPlayers/v1/?appid=1651680");
getdemo = http_get("https://api.steampowered.com/ISteamUserStats/GetNumberOfCurrentPlayers/v1/?appid=1749610");

if steam_get_app_id() = 1749610 { version = "Demo"	}
if steam_get_app_id() != 1749610 { version = "Release 1.0.7"	}
if os_type = os_android { version = "Android Version" }
rousr_dissonance_set_large_image("icon_bigger","Version - "+ string(version))
rousr_dissonance_set_details("In Main Menu")
window_set_caption("The Colorful Creature | " + version)
diffmonth = date_month_span(date_create_datetime(2018, 9, 3, 15, 30, 27 ), date_current_datetime());
diffyear = date_year_span(date_create_datetime(2018, 9, 3, 15, 30, 27 ), date_current_datetime());
diffsecond = date_second_span(date_create_datetime(2018, 9, 3, 15, 30, 27 ), date_current_datetime());
diffyearinfi = date_year_span(date_create_datetime(2003, 11, 18, 01, 30, 30 ), date_current_datetime());
clicked = false

if steam_user_owns_dlc(1651680) { game1 = 1 } else { game1 = 0 }
e1 = 0
e2 = 0
e3 = 0
e4 = 0
if steam_user_owns_dlc(1995510) { dlc1 = 1 } else { dlc1 = 0 }
if steam_user_owns_dlc(1749590) { dlc2 = 1 } else { dlc2 = 0 }
if steam_user_owns_dlc(2407300) { dlc3 = 1 } else { dlc3 = 0 }
hats = 0

moni = 0
actualmoni = 0
global.donatedmoney = 0

if steam_user_owns_dlc(2411810) {
	moni = 1
	actualmoni += 2
}
if steam_user_owns_dlc(2411811) {
	moni = 1
	actualmoni += 3
}
if steam_user_owns_dlc(2411812) {
	moni = 1
	actualmoni += 5
}

global.donatedmoney = actualmoni

//if steam_user_owns_dlc(2411810) {actualmoni = 2 moni = 1}
/*if steam_user_owns_dlc(2411811) {actualmoni = 3 moni = 1}
if steam_user_owns_dlc(2411812) {actualmoni = 5 moni = 1}
if steam_user_owns_dlc(2411812) && steam_user_owns_dlc(2411810) {actualmoni = 7 moni = 1}
if steam_user_owns_dlc(2411812) && steam_user_owns_dlc(2411811) {actualmoni = 8 moni = 1}
if steam_user_owns_dlc(2411812) && steam_user_owns_dlc(2411811) && steam_user_owns_dlc(2411810) {actualmoni = 10 moni = 1}*/

//Go to o_richpresence
rng = 0
somethingwillhappen = irandom_range(100,500)
splash = irandom_range(1,550)

if global.customsplashessettings = 1 {
splashmax = 0
var num = 0;
var dircustomsplash = game_save_id + "/Custom/Custom Splash Texts.txt"
if file_exists(dircustomsplash) {
var file = file_text_open_read(dircustomsplash);
while (!file_text_eof(file))
{
    str[num++] = file_text_readln(file);
	splashmax += 1
}
if splashmax != 0 { 
splash = irandom(splashmax-1)
chosentext = str[splash]
} else {
chosentext = "Trying to crash the game eh? Nice try!"
}
file_text_close(file);
} else {
chosentext = "Trying to crash the game eh? Nice try!"
}
}

//TCC Anniversary
if current_day = 3 {
if current_month = 9 {
splash = -1	
}}
//April Fools
if current_day = 1 {
if current_month = 4 {
splash = -2
}}
//Birthday
if current_day = 18 {
if current_month = 11 {
splash = -3
}}
//Halloween
if current_day = 31 {
if current_month = 10 {
splash = -4
}}
//Christmas
if current_day >= 25 {
if current_month = 12 {
splash = irandom_range(-5,-18)
}}
if current_day <= 7 {
if current_month = 1 {
splash = irandom_range(-5,-18)
}}

//Special Rainbow colors!
red = 255
green = 0
blue = 0
change = 0

alarm[0] = 1000