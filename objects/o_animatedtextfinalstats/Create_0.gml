window_set_cursor(cr_default)
changey = 0
changex = 0
textchange = 0
textspeed = 0.03 * (60 / global.maxfps)
red = 0
blue = 0
green = 0
dist = 2
colorchange = 0
colorthingy = 50
showhighscore = 0
deaths = 0

challenge = 0
challengetime = 0
challengedeaths = 0

leaderboard_id = ""

timer = 75
timer2 = 10
nexttext = 0
x1 = -1000
x2 = -1000
x3 = -1000
x4 = -1000


//Challanges
if global.cheats = 0 {
if global.workshop = 0 {
	var _def = scr_challenge_get_def(global.currentchallenge);
	if (!is_undefined(_def)) {
		challenge = scr_challenge_get_time(_def.id);
		challengetime = challenge;
		challengedeaths = scr_challenge_get_deaths(_def.id);

		if (_def.achievement != "" && !steam_get_achievement(_def.achievement)) {
			steam_set_achievement(_def.achievement);
		}

		if challenge > global.time {
			scr_challenge_set_time(_def.id, global.time);
			challengetime = global.time;
			if (_def.leaderboard != "") {
				steam_upload_score(_def.leaderboard, global.time * 1000);
			}
		}
		if challengedeaths > global.deaths {
			scr_challenge_set_deaths(_def.id, global.deaths);
			challengedeaths = global.deaths;
		}
	}
}

if challenge > global.time {
showhighscore = 1
}

if global.workshop = 0 {
scr_savechallengetime()
scr_savechallengedeaths()

if !steam_get_achievement("FIRST_CHALLENGE") { steam_set_achievement("FIRST_CHALLENGE") }

} else {
	var directory = directory_set("/Custom/Workshop/Medals/" + string(global.Publish_ID) + "/")
	var previoustime = 9999999
	
	if (file_exists(directory + "MedalData.sav")) {
	ini_open(directory + "MedalData.sav");
	previoustime = ini_read_real("Medal Data","Time",9999999);
	} else { }
	
	if previoustime > global.time {
	showhighscore = 1
	global.creditscurrency += floor(5 * global.creditsmultiplier) 
	}
	
}


if os_type = os_android || os_type = os_gxgames {
AdMob_Banner_Create(AdMob_Banner_SMART,true)
AdMob_Banner_Show()
var _def_mobile = scr_challenge_get_def(global.currentchallenge);
if (!is_undefined(_def_mobile) && _def_mobile.leaderboard_mobile != "") {
leaderboard_id = _def_mobile.leaderboard_mobile
}}

alarm[0] = 1
}
