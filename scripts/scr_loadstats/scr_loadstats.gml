function scr_loadstats() {
if global.cheats = 0 {
	var directory = game_save_id + "/Save Files/"
	if (file_exists(directory + "Stats.sav")) {
	ini_open(directory + "Stats.sav");
	global.totaldeaths = ini_read_real("Stats","Total Deaths",0)
	global.totaltime = ini_read_real("Stats","Total Time",0);
	global.totaljumps = ini_read_real("Stats","Total Jumps",0);
	global.totalcoins = ini_read_real("Stats","Total Coins",0);
	global.totalskips = ini_read_real("Stats","Total Skips",0);
	global.totalpickups = ini_read_real("Stats","Total Pickups",0);
	global.totalnormalpickups = ini_read_real("Stats","Total Normal Pickups",0);
	global.totalgravitypickups = ini_read_real("Stats","Total Gravity Pickups",0);
	global.totalspeedpickups = ini_read_real("Stats","Total Speed Pickups",0);
	global.totalusepickups = ini_read_real("Stats","Total Use Pickups",0);
	global.totalkeypickups = ini_read_real("Stats","Total Key Pickups",0);
	global.totalportal = ini_read_real("Stats","Total Portal",0);
	global.totaltorchpickups = ini_read_real("Stats","Total Torch Pickups",0);
	global.totallevelcompleted = ini_read_real("Stats","Total Level Completed",0);
	global.customlevelcompleted = ini_read_real("Stats","Custom Levels Completed",0);
	global.totalgunshots = ini_read_real("Stats","Total Gun Shots",0);
	global.totalgunpickups = ini_read_real("Stats","Total Gun Pickups",0);
	global.totalammopickups = ini_read_real("Stats","Total Ammo Pickups",0);
	global.totaldestroyedboxes = ini_read_real("Stats","Total Destroyed Boxes",0);
	global.totalenemykills = ini_read_real("Stats","Total Enemy Kills",0);
	global.total1ups = ini_read_real("Stats","Total 1UPS",0);
	global.totalrocketkills = ini_read_real("Stats","Total Rocket Kills",0);
	global.totaloxygenpickups = ini_read_real("Stats","Total Oxygen Pickups",0);
	global.cookies = ini_read_real("Stats","Cookies",0);
	global.creditscurrency = ini_read_real("Stats","Credits",0);
	global.wheeltimeleft = ini_read_real("Stats","Wheel Cooldown",0);
	global.customERunlock = ini_read_real("Stats","Custom E.R Unlocked?",0);
	global.oldERunlock = ini_read_real("Stats","Old E.R Unlocked?",0);
	global.totaldjumppickups = ini_read_real("Stats","Total D.Jump Pickups",0);
	global.totalblocksbroken = ini_read_real("Stats","Total Blocks Broken",0);
	global.newcalendarrecord = ini_read_real("Stats","Calendar Record",0);
	global.gamenews = ini_read_real("Stats","Game News",0);
	global.asteroidfun = ini_read_real("Stats","AFUN",0);
	//Deaths
	global.totalblockdeaths = ini_read_real("Stats","Block Deaths",0);
	global.totalrestartdeaths = ini_read_real("Stats","Restart Deaths",0);
	global.totalspikedeaths = ini_read_real("Stats","Spike Deaths",0);
	global.totalinvisiblespikedeaths = ini_read_real("Stats","I.Spike Deaths",0);
	global.totalverticalspikedeaths = ini_read_real("Stats","V.Spike Deaths",0);
	global.totalhorizontalspikedeaths = ini_read_real("Stats","H.Spike Deaths",0);
	global.totalgoldspikedeaths = ini_read_real("Stats","G.Spike Deaths",0);
	global.totalweirdspikedeaths = ini_read_real("Stats","W.Spike Deaths",0);
	global.totalvoiddeaths = ini_read_real("Stats","Void Deaths",0);
	global.totalfiredeaths = ini_read_real("Stats","Fire Deaths",0);
	global.totallavadeaths = ini_read_real("Stats","Lava Deaths",0);
	global.totalbulletdeaths = ini_read_real("Stats","Bullet Deaths",0);
	global.totalrocketdeaths = ini_read_real("Stats","Rocket Deaths",0);
	global.totaltroopdeaths = ini_read_real("Stats","Troop Deaths",0);
	global.totalwaterdeaths = ini_read_real("Stats","Water Deaths",0);
	}
	else {
	}
	}

}
