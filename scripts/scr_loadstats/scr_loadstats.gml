function scr_loadstats() {
if global.cheats = 0 {
	var directory = directory_set("//Save Files/")

	scr_save_recover(directory + "Stats.sav");
	if (file_exists(directory + "Stats.sav")) {
	ini_open(directory + "Stats.sav");
	//STATS
	global.totaldeaths = scr_save_number("Stats","Total Deaths",0)
	global.totaltime = scr_save_number("Stats","Total Time",0);
	global.totaljumps = scr_save_number("Stats","Total Jumps",0);
	global.totalcoins = scr_save_number("Stats","Total Coins",0);
	global.totalskips = scr_save_number("Stats","Total Skips",0);
	global.totalpickups = scr_save_number("Stats","Total Pickups",0);
	global.totalnormalpickups = scr_save_number("Stats","Total Normal Pickups",0);
	global.totalgravitypickups = scr_save_number("Stats","Total Gravity Pickups",0);
	global.totalspeedpickups = scr_save_number("Stats","Total Speed Pickups",0);
	global.totalusepickups = scr_save_number("Stats","Total Use Pickups",0);
	global.totalkeypickups = scr_save_number("Stats","Total Key Pickups",0);
	global.totalportal = scr_save_number("Stats","Total Portal",0);
	global.totaltorchpickups = scr_save_number("Stats","Total Torch Pickups",0);
	global.totallevelcompleted = scr_save_number("Stats","Total Level Completed",0);
	global.customlevelcompleted = scr_save_number("Stats","Custom Levels Completed",0);
	global.totalgunshots = scr_save_number("Stats","Total Gun Shots",0);
	global.totalgunpickups = scr_save_number("Stats","Total Gun Pickups",0);
	global.totalammopickups = scr_save_number("Stats","Total Ammo Pickups",0);
	global.totaldestroyedboxes = scr_save_number("Stats","Total Destroyed Boxes",0);
	global.totalenemykills = scr_save_number("Stats","Total Enemy Kills",0);
	global.total1ups = scr_save_number("Stats","Total 1UPS",0);
	global.totalrocketkills = scr_save_number("Stats","Total Rocket Kills",0);
	global.totaloxygenpickups = scr_save_number("Stats","Total Oxygen Pickups",0);
	global.creditscurrency = scr_save_number("Stats","Credits",0);
	global.wheeltimeleft = scr_save_number("Stats","Wheel Cooldown",0);
	global.wheelskincooldown = scr_save_number("Stats","Wheel Skin Cooldown",0);
	global.customERunlock = scr_save_number("Stats","Custom E.R Unlocked?",0);
	global.oldERunlock = scr_save_number("Stats","Old E.R Unlocked?",0);
	global.totaldjumppickups = scr_save_number("Stats","Total D.Jump Pickups",0);
	global.totalblocksbroken = scr_save_number("Stats","Total Blocks Broken",0);
	global.newcalendarrecord = scr_save_number("Stats","Calendar Record",0);
	global.gamenews = scr_save_number("Stats","Game News",0);
	global.asteroidfun = scr_save_number("Stats","AFUN",0);
	global.worldProgression = scr_save_number("Stats","worldProgression",1);
	global.totalquests = scr_save_number("Stats","Total Quests Beaten",1);
	//Deaths
	global.totalblockdeaths = scr_save_number("Stats","Block Deaths",0);
	global.totalrestartdeaths = scr_save_number("Stats","Restart Deaths",0);
	global.totalspikedeaths = scr_save_number("Stats","Spike Deaths",0);
	global.totalinvisiblespikedeaths = scr_save_number("Stats","I.Spike Deaths",0);
	global.totalverticalspikedeaths = scr_save_number("Stats","V.Spike Deaths",0);
	global.totalhorizontalspikedeaths = scr_save_number("Stats","H.Spike Deaths",0);
	global.totalgoldspikedeaths = scr_save_number("Stats","G.Spike Deaths",0);
	global.totalweirdspikedeaths = scr_save_number("Stats","W.Spike Deaths",0);
	global.totalvoiddeaths = scr_save_number("Stats","Void Deaths",0);
	global.totalfiredeaths = scr_save_number("Stats","Fire Deaths",0);
	global.totallavadeaths = scr_save_number("Stats","Lava Deaths",0);
	global.totalbulletdeaths = scr_save_number("Stats","Bullet Deaths",0);
	global.totalrocketdeaths = scr_save_number("Stats","Rocket Deaths",0);
	global.totaltroopdeaths = scr_save_number("Stats","Troop Deaths",0);
	global.totalwaterdeaths = scr_save_number("Stats","Water Deaths",0);

	//QUESTS
	for(var i=0;i<5;i++) {
		global.QUEST[i] = scr_save_number("Quests","QuestN"+string(i),0)
	}
	global.QUESTday = scr_save_number("Quests","Quest Day",global.calendarcurrentday)

	global.QUESTdeaths = scr_save_number("Quests","Total Deaths",0)
	global.QUESTtime = scr_save_number("Quests","Total Time",0);
	global.QUESTjump = scr_save_number("Quests","Total Jumps",0);
	global.QUESTcoins = scr_save_number("Quests","Total Coins",0);
    global.QUESTskip = scr_save_number("Quests","Total Skips",0);
    global.QUESTnormalpickups = scr_save_number("Quests","Total Normal Pickups",0);
    global.QUESTgravitypickups = scr_save_number("Quests","Total Gravity Pickups",0);
    global.QUESTspeedpickups = scr_save_number("Quests","Total Speed Pickups",0);
    global.QUESTusepickups = scr_save_number("Quests","Total Use Pickups",0);
    global.QUESTkeypickups = scr_save_number("Quests","Total Key Pickups",0);
    global.QUESTportal = scr_save_number("Quests","Total Portal",0);
    global.QUESTtorchpickups = scr_save_number("Quests","Total Torch Pickups",0);
    global.QUESTlevelcompleted = scr_save_number("Quests","Total Level Completed",0);
    global.QUESTcustomlevel = scr_save_number("Quests","Custom Levels Completed",0);
    global.QUESTgunshots = scr_save_number("Quests","Total Gun Shots",0);
    global.QUESTgunpickups = scr_save_number("Quests","Total Gun Pickups",0);
    global.QUESTammopickups = scr_save_number("Quests","Total Ammo Pickups",0);
    global.QUESTdestroyedboxes = scr_save_number("Quests","Total Destroyed Boxes",0);
    global.QUESTenemykills = scr_save_number("Quests","Total Enemy Kills",0);
    global.QUEST1ups = scr_save_number("Quests","Total 1UPS",0);
    global.QUESTrocketkills = scr_save_number("Quests","Total Rocket Kills",0);
    global.QUESToxygenpickups = scr_save_number("Quests","Total Oxygen Pickups",0);
    global.QUESTdjumppickups = scr_save_number("Quests","Total D.Jump Pickups",0);
    global.QUESTblocksbroken = scr_save_number("Quests","Total Blocks Broken",0);

    global.QUESTblockdeaths = scr_save_number("Quests","Block Deaths",0);
	ini_close();
    global.QUESTrestartdeaths = 0
    global.QUESTspikedeaths = 0
    global.QUESTinvisiblespikedeaths = 0
    global.QUESTverticalspikedeaths = 0
    global.QUESThorizontalspikedeaths = 0
    global.QUESTgoldspikedeaths = 0
    global.QUESTweirdspikedeaths = 0
    global.QUESTvoiddeaths = 0
    global.QUESTfiredeaths = 0
    global.QUESTlavadeaths = 0
    global.QUESTbulletdeaths = 0
    global.QUESTrocketdeaths = 0
    global.QUESTtroopdeaths = 0
    global.QUESTwaterdeaths = 0
	}
	else {
	}
	}

}
