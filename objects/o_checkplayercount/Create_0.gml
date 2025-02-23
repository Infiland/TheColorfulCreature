if os_browser != browser_not_a_browser {
	instance_destroy()	
}

r_str = "0"
global.playercount = 0
global.playercountdemo = 0
global.creditsmultiplier = 1

//Get Player count from the game and demo
//get = http_get("https://api.steampowered.com/ISteamUserStats/GetNumberOfCurrentPlayers/v1/?appid=1651680");
//getdemo = http_get("https://api.steampowered.com/ISteamUserStats/GetNumberOfCurrentPlayers/v1/?appid=1749610");

busy = false; // are we busy with the request?
success = false; // did we obtain a number successfully?
players = 0; // the actual number, can be 0

if (variable_global_exists("steam_is_available") && global.steam_is_available) {
    if (steam_get_number_of_current_players()) {
        busy = true;
    }
}

//Refresh
alarm[0] = 500