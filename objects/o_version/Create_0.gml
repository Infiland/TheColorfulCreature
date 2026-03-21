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

} else {
    // Default values when Steam is not available
    version = "Release " + GM_version
    busy = false
    success = false
    players = 0
}

// Check DLC and donation ownership
var dlc_data = badge_check_dlc_ownership();
game1 = dlc_data.game1;
dlc1 = dlc_data.dlc1;
dlc1_1 = dlc_data.dlc1_1;
dlc2 = dlc_data.dlc2;
dlc3 = dlc_data.dlc3;
moni = dlc_data.moni;
actualmoni = dlc_data.actualmoni;
global.donatedmoney = actualmoni;

// Set version for special cases
if (global.moddedGameDir != "") { version = loc("MODDED_CLIENT") } // MODDED VERSION
if (os_type == os_android) { version = "Android Version" } // ANDROID VERSION
if (os_type == os_gxgames) { version = "Website Version" } // WEB VERSION

window_set_caption("The Colorful Creature | " + version)

// Calculate time differences
diffmonth = date_month_span(date_create_datetime(2018, 9, 3, 15, 30, 27), date_current_datetime());
diffyear = date_year_span(date_create_datetime(2018, 9, 3, 15, 30, 27), date_current_datetime());
diffsecond = date_second_span(date_create_datetime(2018, 9, 3, 15, 30, 27), date_current_datetime());
diffyearinfi = date_year_span(date_create_datetime(2003, 11, 18, 01, 30, 30), date_current_datetime());

clicked = false

// Load seasonal endless run rankings from JSON
var rankings = badge_load_seasonal_rankings();
e1 = rankings.e1;
e2 = rankings.e2;
e3 = rankings.e3;
e4 = rankings.e4;
hats = rankings.hats;

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