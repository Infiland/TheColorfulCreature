get = http_get("https://api.steampowered.com/ISteamUserStats/GetNumberOfCurrentPlayers/v1/?appid=1651680");
getdemo = http_get("https://api.steampowered.com/ISteamUserStats/GetNumberOfCurrentPlayers/v1/?appid=1749610");

if os_is_network_connected() {
if global.playercount > 1 {
global.creditsmultiplier = 1 + (global.playercount * 0.05) + (global.playercountdemo * 0.01)
}} else {
global.creditsmultiplier = 1
}
if global.creditsmultiplier > 3 {
global.creditsmultiplier = 3
}
alarm[0] = 500