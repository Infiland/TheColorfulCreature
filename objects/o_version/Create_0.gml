/// @description Game's Version
randomize()
global._ef_water.cutoff = 20000
global._ef_gain.gain = 1
r_str = "0"

// Initialize Steam-related variables
global.steam_is_available = false
if (variable_global_exists("steam_is_running")) {
    global.steam_is_available = steam_is_running()
}

// Only make Steam API calls if Steam is available
if (global.steam_is_available) {
    get = http_get("https://api.steampowered.com/ISteamUserStats/GetNumberOfCurrentPlayers/v1/?appid=1651680");
    getdemo = http_get("https://api.steampowered.com/ISteamUserStats/GetNumberOfCurrentPlayers/v1/?appid=1749610");

    busy = false; // are we busy with the request?
    success = false; // did we obtain a number successfully?
    players = 0; // the actual number, can be 0
    if (steam_get_number_of_current_players()) {
        busy = true; // waiting for the request
    }

    // Set version based on Steam app ID
    if (steam_get_app_id() == 1749610) { 
        version = "Demo"	
    } else {
        version = "Release " + GM_version 
    }

    // Check DLC ownership
    if (steam_user_owns_dlc(1651680)) { game1 = 1 } else { game1 = 0 } //If the player owns the game
    if (steam_user_owns_dlc(1749590)) { dlc1 = 1 } else { dlc1 = 0 } //TCC OST
    if (steam_user_owns_dlc(1749600)) { dlc1 = 1 dlc1_1 = 1 } else { dlc1 = 0 dlc1_1 = 0 } //TCC Super OST
    if (steam_user_owns_dlc(1995510)) { dlc2 = 1 } else { dlc2 = 0 } //Commentary DLC
    if (steam_user_owns_dlc(2407300)) { dlc3 = 1 } else { dlc3 = 0 } //Asteroids
} else {
    // Default values when Steam is not available
    version = "Release " + GM_version
    game1 = 0
    dlc1 = 0
    dlc1_1 = 0
    dlc2 = 0
    dlc3 = 0
    busy = false
    success = false
    players = 0
}

// Set version for special cases
if (global.moddedGameDir != "") { version = loc(677) } // MODDED VERSION
if (os_type == os_android) { version = "Android Version" } // ANDROID VERSION
if (os_type == os_gxgames) { version = "Website Version" } // WEB VERSION

window_set_caption("The Colorful Creature | " + version)

// Calculate time differences
diffmonth = date_month_span(date_create_datetime(2018, 9, 3, 15, 30, 27), date_current_datetime());
diffyear = date_year_span(date_create_datetime(2018, 9, 3, 15, 30, 27), date_current_datetime());
diffsecond = date_second_span(date_create_datetime(2018, 9, 3, 15, 30, 27), date_current_datetime());
diffyearinfi = date_year_span(date_create_datetime(2003, 11, 18, 01, 30, 30), date_current_datetime());

clicked = false
e1 = 0 //Seasonal Endless Gold
e2 = 0 //Seasonal Endless Silver
e3 = 0 //Seasonal Endless Bronze
e4 = 0 //Seasonal Endless Top 10
hats = 0
moni = 0
actualmoni = 0
global.donatedmoney = 0

// Check for donations and update badge counts
if steam_user_owns_dlc(2411810) { //2 Euro donation
	moni = 1
	actualmoni += 2
}
if steam_user_owns_dlc(2411811) { //3 Euro donation
	moni = 1
	actualmoni += 3
}
if steam_user_owns_dlc(2411812) { //5 Euro donation
	moni = 1
	actualmoni += 5
}

global.donatedmoney = actualmoni

// Create badge instance if it doesn't exist
if (!instance_exists(o_badge)) {
    instance_create_depth(0, 0, depth-1, o_badge);
}

// Update badge status based on data
// This will be called every time data changes
event_user(0);

rng = 0

//Splash Text
splashmax = 0
var num = 0;
if global.customsplashessettings = 1 {
//Custom splash texts
var dirsplash = game_save_id + "/Custom/Custom Splash Texts.txt"
} else {
//Default Splash Text lineup
var dirsplash = program_directory + "/Other/splash.txt"
//Christmas
if current_day >= 25 && current_month = 12 || current_day <= 7 && current_month = 1 {
	var dirsplash = program_directory + "/Other/splashchristmas.txt"
}
}

//Loading the splashtext .txt file
if file_exists(dirsplash) {
var file = file_text_open_read(dirsplash);
while (!file_text_eof(file))
{
    str[num++] = file_text_readln(file);
	splashmax += 1
}
if splashmax != 0 { 
splash = irandom(splashmax-1)
splashtext = str[splash]
} else {
splashtext = ""
}
file_text_close(file);
} else {
splashtext = ""
}

/*
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
}}*/

//Special Rainbow colors!
red = 255
green = 0
blue = 0
change = 0

alarm[0] = 1000