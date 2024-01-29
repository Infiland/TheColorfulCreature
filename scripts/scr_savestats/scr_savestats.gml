function scr_savestats() {
if global.cheats = 0 {
	var directory = directory_set("//Save Files/")

	if (file_exists(directory + "Stats.sav")) file_delete(directory +"Stats.sav");
	ini_open(directory + "Stats.sav");
	ini_write_real("Stats","Total Deaths",global.totaldeaths);
	ini_write_real("Stats","Total Time",global.totaltime);
	ini_write_real("Stats","Total Jumps",global.totaljumps);
	ini_write_real("Stats","Total Coins",global.totalcoins);
	ini_write_real("Stats","Total Skips",global.totalskips);
	ini_write_real("Stats","Total Pickups",global.totalpickups);
	ini_write_real("Stats","Total Normal Pickups",global.totalnormalpickups);
	ini_write_real("Stats","Total Gravity Pickups",global.totalgravitypickups);
	ini_write_real("Stats","Total Speed Pickups",global.totalspeedpickups);
	ini_write_real("Stats","Total Use Pickups",global.totalusepickups);
	ini_write_real("Stats","Total Key Pickups",global.totalkeypickups);
	ini_write_real("Stats","Total Portal",global.totalportal);
	ini_write_real("Stats","Total Torch Pickups",global.totaltorchpickups);
	ini_write_real("Stats","Total Level Completed",global.totallevelcompleted);
	ini_write_real("Stats","Custom Levels Completed",global.customlevelcompleted);
	ini_write_real("Stats","Total Gun Shots",global.totalgunshots);
	ini_write_real("Stats","Total Gun Pickups",global.totalgunpickups);
	ini_write_real("Stats","Total Ammo Pickups",global.totalammopickups);
	ini_write_real("Stats","Total Destroyed Boxes",global.totaldestroyedboxes);
	ini_write_real("Stats","Total Enemy Kills",global.totalenemykills);
	ini_write_real("Stats","Total 1UPS",global.total1ups);
	ini_write_real("Stats","Total Rocket Kills",global.totalrocketkills);
	ini_write_real("Stats","Total Oxygen Pickups",global.totaloxygenpickups);
	ini_write_real("Stats","Cookies",global.cookies);
	ini_write_real("Stats","Credits",global.creditscurrency);
	ini_write_real("Stats","Wheel Cooldown",global.wheeltimeleft);
	ini_write_real("Stats","Wheel Skin Cooldown",global.wheelskincooldown);
	ini_write_real("Stats","Custom E.R Unlocked?",global.customERunlock);
	ini_write_real("Stats","Old E.R Unlocked?",global.oldERunlock);
	ini_write_real("Stats","Total D.Jump Pickups",global.totaldjumppickups);
	ini_write_real("Stats","Total Blocks Broken",global.totalblocksbroken);
	ini_write_real("Stats","Calendar Record",global.newcalendarrecord);
	ini_write_real("Stats","Game News",global.gamenews);
	ini_write_real("Stats","AFUN",global.asteroidfun);
	ini_write_real("Stats","worldProgression",global.worldProgression);
	//Deaths
	ini_write_real("Stats","Block Deaths",global.totalblockdeaths);
	ini_write_real("Stats","Restart Deaths",global.totalrestartdeaths);
	ini_write_real("Stats","Spike Deaths",global.totalspikedeaths);
	ini_write_real("Stats","I.Spike Deaths",global.totalinvisiblespikedeaths);
	ini_write_real("Stats","V.Spike Deaths",global.totalverticalspikedeaths);
	ini_write_real("Stats","H.Spike Deaths",global.totalhorizontalspikedeaths);
	ini_write_real("Stats","G.Spike Deaths",global.totalgoldspikedeaths);
	ini_write_real("Stats","W.Spike Deaths",global.totalweirdspikedeaths);
	ini_write_real("Stats","Void Deaths",global.totalvoiddeaths);
	ini_write_real("Stats","Fire Deaths",global.totalfiredeaths);
	ini_write_real("Stats","Lava Deaths",global.totallavadeaths);
	ini_write_real("Stats","Bullet Deaths",global.totalbulletdeaths);
	ini_write_real("Stats","Rocket Deaths",global.totalrocketdeaths);
	ini_write_real("Stats","Troop Deaths",global.totaltroopdeaths);
	ini_write_real("Stats","Water Deaths",global.totalwaterdeaths);
	ini_close();
	}
	
	//Achievements
	scr_checkachievements()
	
}
