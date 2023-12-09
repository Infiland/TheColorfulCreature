r_str = "0"
global.playercount = 0
global.playercountdemo = 0
global.creditsmultiplier = 1


get = http_get("https://api.steampowered.com/ISteamUserStats/GetNumberOfCurrentPlayers/v1/?appid=1651680");
getdemo = http_get("https://api.steampowered.com/ISteamUserStats/GetNumberOfCurrentPlayers/v1/?appid=1749610");

alarm[0] = 500