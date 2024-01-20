function scr_loadchallengetime() {
	if global.cheats = 0 {
		
	var directory = directory_set("//Save Files/")
	
	if (file_exists(directory + "ChallengeTime.sav")) {
	ini_open(directory + "ChallengeTime.sav");
	global.tutorialchallengetime = ini_read_real("Challenges","Tutorial Challenge",999999)
	global.ladderchallengetime = ini_read_real("Challenges","Ladder Challenge",999999)
	global.bigroomchallengetime = ini_read_real("Challenges","Big Room Challenge",999999)
	global.slipperychallengetime = ini_read_real("Challenges","Slippery Challenge",999999)
	global.blindchallengetime = ini_read_real("Challenges","Blind Challenge",999999)
	global.troopchallengetime = ini_read_real("Challenges","Troop Challenge",999999)
	global.speedchallengetime = ini_read_real("Challenges","Speed Challenge",999999)
	global.spikechallengetime = ini_read_real("Challenges","Spike Challenge",999999)
	global.kaizochallengetime = ini_read_real("Challenges","Kaizo Challenge",999999)
	global.world6challengetime = ini_read_real("Challenges","World 6 Challenge",999999)
	global.waterchallengetime = ini_read_real("Challenges","Water Challenge",999999)
	global.movingchallengetime = ini_read_real("Challenges","Moving Challenge",999999)
	global.communitychallengetime = ini_read_real("Challenges","Community Challenge",999999)
	global.djumpchallengetime = ini_read_real("Challenges","D.Jump Challenge",999999)
	global.cspikechallengetime = ini_read_real("Challenges","C.Spike Challenge",999999)
	global.world7challengetime = ini_read_real("Challenges","World 7 Challenge",999999)
	global.invisiblechallengetime = ini_read_real("Challenges","Invisible Challenge",999999)
	global.breakablechallengetime = ini_read_real("Challenges","Breakable Challenge",999999)
	} else {
	
	}
	}

}
