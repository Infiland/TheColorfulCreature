function scr_savechallengetime() {
	if global.cheats = 0 {
	var directory = game_save_id
	if global.moddedGameDir != "" { directory += "MODS//" + string(global.moddedGameDir) }
	directory += "//Save Files/"
	
	if (file_exists(directory + "ChallengeTime.sav")) file_delete(directory + "ChallengeTime.sav");
	ini_open(directory + "ChallengeTime.sav");
	ini_write_real("Challenges","Tutorial Challenge",global.tutorialchallengetime);
	ini_write_real("Challenges","Ladder Challenge",global.ladderchallengetime);
	ini_write_real("Challenges","Big Room Challenge",global.bigroomchallengetime);
	ini_write_real("Challenges","Slippery Challenge",global.slipperychallengetime);
	ini_write_real("Challenges","Blind Challenge",global.blindchallengetime);
	ini_write_real("Challenges","Troop Challenge",global.troopchallengetime);
	ini_write_real("Challenges","Speed Challenge",global.speedchallengetime);
	ini_write_real("Challenges","Spike Challenge",global.spikechallengetime);
	ini_write_real("Challenges","Kaizo Challenge",global.kaizochallengetime);
	ini_write_real("Challenges","World 6 Challenge",global.world6challengetime);
	ini_write_real("Challenges","Water Challenge",global.waterchallengetime);
	ini_write_real("Challenges","Moving Challenge",global.movingchallengetime);
	ini_write_real("Challenges","Community Challenge",global.communitychallengetime);
	ini_write_real("Challenges","D.Jump Challenge",global.djumpchallengetime);
	ini_write_real("Challenges","C.Spike Challenge",global.cspikechallengetime);
	ini_write_real("Challenges","World 7 Challenge",global.world7challengetime);
	ini_write_real("Challenges","Invisible Challenge",global.invisiblechallengetime);
	ini_write_real("Challenges","Breakable Challenge",global.breakablechallengetime);
	
	ini_close();
	}
}
