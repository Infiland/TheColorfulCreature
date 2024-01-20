function scr_loadchallengedeaths() {
	if global.cheats = 0 {
		
	var directory = directory_set("//Save Files/")
	
	if (file_exists(directory + "ChallengeDeaths.sav")) {
	ini_open(directory + "ChallengeDeaths.sav");
	global.tutorialchallengedeaths = ini_read_real("Challenges","Tutorial Challenge",999999)
	global.ladderchallengedeaths = ini_read_real("Challenges","Ladder Challenge",999999)
	global.bigroomchallengedeaths = ini_read_real("Challenges","Big Room Challenge",999999)
	global.slipperychallengedeaths = ini_read_real("Challenges","Slippery Challenge",999999)
	global.blindchallengedeaths = ini_read_real("Challenges","Blind Challenge",999999)
	global.troopchallengedeaths = ini_read_real("Challenges","Troop Challenge",999999)
	global.speedchallengedeaths = ini_read_real("Challenges","Speed Challenge",999999)
	global.spikechallengedeaths = ini_read_real("Challenges","Spike Challenge",999999)
	global.kaizochallengedeaths = ini_read_real("Challenges","Kaizo Challenge",999999)
	global.world6challengedeaths = ini_read_real("Challenges","World 6 Challenge",999999)
	global.waterchallengedeaths = ini_read_real("Challenges","Water Challenge",999999)
	global.movingchallengedeaths = ini_read_real("Challenges","Moving Challenge",999999)
	global.communitychallengedeaths = ini_read_real("Challenges","Community Challenge",999999)
	global.djumpchallengedeaths = ini_read_real("Challenges","D.Jump Challenge",999999)
	global.cspikechallengedeaths = ini_read_real("Challenges","C.Spike Challenge",999999)
	global.world7challengedeaths = ini_read_real("Challenges","World 7 Challenge",999999)
	global.invisiblechallengedeaths = ini_read_real("Challenges","Invisible Challenge",999999)
	global.breakablechallengedeaths = ini_read_real("Challenges","Breakable Challenge",999999)
	} else {
	
	}
	}

}
