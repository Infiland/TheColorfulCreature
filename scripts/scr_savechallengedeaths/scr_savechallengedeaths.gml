function scr_savechallengedeaths() {
	if global.cheats = 0 {
	var directory = working_directory + "/Save Files/"
	if (file_exists(directory + "ChallengeDeaths.sav")) file_delete(directory + "ChallengeDeaths.sav");
	ini_open(directory + "ChallengeDeaths.sav");
	ini_write_real("Challenges","Tutorial Challenge",global.tutorialchallengedeaths);
	ini_write_real("Challenges","Ladder Challenge",global.ladderchallengedeaths);
	ini_write_real("Challenges","Big Room Challenge",global.bigroomchallengedeaths);
	ini_write_real("Challenges","Slippery Challenge",global.slipperychallengedeaths);
	ini_write_real("Challenges","Blind Challenge",global.blindchallengedeaths);
	ini_write_real("Challenges","Troop Challenge",global.troopchallengedeaths);
	ini_write_real("Challenges","Speed Challenge",global.speedchallengedeaths);
	ini_write_real("Challenges","Spike Challenge",global.spikechallengedeaths);
	ini_write_real("Challenges","Kaizo Challenge",global.kaizochallengedeaths);
	ini_write_real("Challenges","World 6 Challenge",global.world6challengedeaths);
	ini_write_real("Challenges","Water Challenge",global.waterchallengedeaths);
	ini_write_real("Challenges","Moving Challenge",global.movingchallengedeaths);
	ini_write_real("Challenges","Community Challenge",global.communitychallengedeaths);
	ini_write_real("Challenges","D.Jump Challenge",global.djumpchallengedeaths);
	ini_write_real("Challenges","C.Spike Challenge",global.cspikechallengedeaths);
	ini_write_real("Challenges","World 7 Challenge",global.world7challengedeaths);
	ini_write_real("Challenges","Invisible Challenge",global.invisiblechallengedeaths);
	ini_write_real("Challenges","Breakable Challenge",global.breakablechallengedeaths);
	ini_close();
	}
}
