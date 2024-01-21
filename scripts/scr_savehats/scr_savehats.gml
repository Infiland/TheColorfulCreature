function scr_savehats() {
if global.cheats = 0 {
	
	var directory = directory_set("//Save Files/")
	
	if (file_exists(directory + "Hats.sav")) file_delete(directory + "Hats.sav");
	ini_open(directory + "Hats.sav");
	//Hats
	ini_write_real("Hats","Selected Hat",global.hatselected);
	ini_write_real("Hats","Graduated Hat",global.hat001);
	ini_write_real("Hats","Cone Hat",global.hat002);
	ini_write_real("Hats","Party Hat",global.hat003);
	ini_write_real("Hats","Paper Hat",global.hat004);
	ini_write_real("Hats","Top Hat",global.hat005);
	ini_write_real("Hats","Yellow Top Hat",global.hat006);
	ini_write_real("Hats","Reddie Hat",global.hat007);
	ini_write_real("Hats","Christmas Hat",global.hat008);
	ini_write_real("Hats","Witch Hat",global.hat009);
	ini_write_real("Hats","Pumpkin Hat",global.hat010);
	ini_write_real("Hats","Brown Cap",global.hat011);
	ini_write_real("Hats","Gray Cap",global.hat012);
	ini_write_real("Hats","White Cap",global.hat013);
	ini_write_real("Hats","Sun Hat",global.hat014);
	ini_write_real("Hats","Red Block Hat",global.hat015);
	ini_write_real("Hats","Yellow Block Hat",global.hat016);
	ini_write_real("Hats","Green Block Hat",global.hat017);
	ini_write_real("Hats","Blue Block Hat",global.hat018);
	ini_write_real("Hats","White Block Hat",global.hat019);
	ini_write_real("Hats","Spike Hat",global.hat020);
	ini_write_real("Hats","Invisible Spike Hat",global.hat021);
	ini_write_real("Hats","Vertical Moving Spike Hat",global.hat022);
	ini_write_real("Hats","Horizontal Moving Spike Hat",global.hat023);
	ini_write_real("Hats","Hexagon Hat",global.hat024);
	ini_write_real("Hats","Bread Hat",global.hat025);
	ini_write_real("Hats","Soldier Hat",global.hat026);
	ini_write_real("Hats","Samurai Hat",global.hat027);
	ini_write_real("Hats","Red Beanie Hat",global.hat028);
	ini_write_real("Hats","Yellow Beanie Hat",global.hat029);
	ini_write_real("Hats","Green Beanie Hat",global.hat030);
	ini_write_real("Hats","Blue Beanie Hat",global.hat031);
	ini_write_real("Hats","White Beanie Hat",global.hat032);
	ini_write_real("Hats","Pirate Hat",global.hat033);
	ini_write_real("Hats","Pink Bowtie Hat",global.hat034);
	ini_write_real("Hats","King's Hat",global.hat035);
	ini_write_real("Hats","Hair",global.hat036);
	ini_write_real("Hats","Comrade Hat",global.hat037);
	ini_write_real("Hats","Viking Hat",global.hat038);
	ini_write_real("Hats","Cowboy Hat",global.hat039);
	ini_write_real("Hats","Red Sus Hat",global.hat040);
	ini_write_real("Hats","Yellow Sus Hat",global.hat041);
	ini_write_real("Hats","Green Sus Hat",global.hat042);
	ini_write_real("Hats","Blue Sus Hat",global.hat043);
	ini_write_real("Hats","White Sus Hat",global.hat044);
	ini_write_real("Hats","Flower Hat",global.hat045);
	ini_write_real("Hats","Propeller Hat",global.hat046);
	ini_write_real("Hats","Serbian Hat",global.hat047);
	ini_write_real("Hats","Rat Hat",global.hat048);
	ini_write_real("Hats","German Hat",global.hat049);
	ini_write_real("Hats","French Hat",global.hat050);
	ini_write_real("Hats","Italian Hat",global.hat051);
	ini_write_real("Hats","Spanish Hat",global.hat052);
	ini_write_real("Hats","Magyar Hat",global.hat053);
	ini_write_real("Hats","Bosnian Hat",global.hat054);
	ini_write_real("Hats","Chinese Hat",global.hat055);
	ini_write_real("Hats","Ukraine Hat",global.hat056);
	ini_write_real("Hats","Macedonian Hat",global.hat057);
	ini_write_real("Hats","Chicken Hat",global.hat058);
	ini_write_real("Hats","Czech Hat",global.hat059);
	ini_write_real("Hats","Russian Hat",global.hat060);
	ini_write_real("Hats","Devil Hat",global.hat061);
	ini_write_real("Hats","Turkish Hat",global.hat062)
	ini_write_real("Hats","Palestinian Hat",global.hat063)
	
	ini_write_string("CustomHat","Custom Hat",global.CUSTOMhat);
	ini_close();
}
}