function scr_savehats() {
if global.cheats = 0 {
	
	var directory = directory_set("//Save Files/")
	
	if (file_exists(directory + "Hats.sav")) file_delete(directory + "Hats.sav");
	ini_open(directory + "Hats.sav");
	//Hats
	ini_write_real("Hats","Selected Hat",global.hatselected);
	ini_write_real("Hats","Hat Name Object Selected",global.hatnameobjectselected)
	ini_write_real("Hats","Graduated Hat",global.hat[1]);
	ini_write_real("Hats","Cone Hat",global.hat[2]);
	ini_write_real("Hats","Party Hat",global.hat[3]);
	ini_write_real("Hats","Paper Hat",global.hat[4]);
	ini_write_real("Hats","Top Hat",global.hat[5]);
	ini_write_real("Hats","Yellow Top Hat",global.hat[6]);
	ini_write_real("Hats","Reddie Hat",global.hat[7]);
	ini_write_real("Hats","Christmas Hat",global.hat[8]);
	ini_write_real("Hats","Witch Hat",global.hat[9]);
	ini_write_real("Hats","Pumpkin Hat",global.hat[10]);
	ini_write_real("Hats","Brown Cap",global.hat[11]);
	ini_write_real("Hats","Gray Cap",global.hat[12]);
	ini_write_real("Hats","White Cap",global.hat[13]);
	ini_write_real("Hats","Sun Hat",global.hat[14]);
	ini_write_real("Hats","Red Block Hat",global.hat[15]);
	ini_write_real("Hats","Yellow Block Hat",global.hat[16]);
	ini_write_real("Hats","Green Block Hat",global.hat[17]);
	ini_write_real("Hats","Blue Block Hat",global.hat[18]);
	ini_write_real("Hats","White Block Hat",global.hat[19]);
	ini_write_real("Hats","Spike Hat",global.hat[20]);
	ini_write_real("Hats","Invisible Spike Hat",global.hat[21]);
	ini_write_real("Hats","Vertical Moving Spike Hat",global.hat[22]);
	ini_write_real("Hats","Horizontal Moving Spike Hat",global.hat[23]);
	ini_write_real("Hats","Hexagon Hat",global.hat[24]);
	ini_write_real("Hats","Bread Hat",global.hat[25]);
	ini_write_real("Hats","Soldier Hat",global.hat[26]);
	ini_write_real("Hats","Samurai Hat",global.hat[27]);
	ini_write_real("Hats","Red Beanie Hat",global.hat[28]);
	ini_write_real("Hats","Yellow Beanie Hat",global.hat[29]);
	ini_write_real("Hats","Green Beanie Hat",global.hat[30]);
	ini_write_real("Hats","Blue Beanie Hat",global.hat[31]);
	ini_write_real("Hats","White Beanie Hat",global.hat[32]);
	ini_write_real("Hats","Pirate Hat",global.hat[33]);
	ini_write_real("Hats","Pink Bowtie Hat",global.hat[34]);
	ini_write_real("Hats","King's Hat",global.hat[35]);
	ini_write_real("Hats","Hair",global.hat[36]);
	ini_write_real("Hats","Comrade Hat",global.hat[37]);
	ini_write_real("Hats","Viking Hat",global.hat[38]);
	ini_write_real("Hats","Cowboy Hat",global.hat[39]);
	ini_write_real("Hats","Red Sus Hat",global.hat[40]);
	ini_write_real("Hats","Yellow Sus Hat",global.hat[41]);
	ini_write_real("Hats","Green Sus Hat",global.hat[42]);
	ini_write_real("Hats","Blue Sus Hat",global.hat[43]);
	ini_write_real("Hats","White Sus Hat",global.hat[44]);
	ini_write_real("Hats","Flower Hat",global.hat[45]);
	ini_write_real("Hats","Propeller Hat",global.hat[46]);
	ini_write_real("Hats","Serbian Hat",global.hat[47]);
	ini_write_real("Hats","Rat Hat",global.hat[48]);
	ini_write_real("Hats","German Hat",global.hat[49]);
	ini_write_real("Hats","French Hat",global.hat[50]);
	ini_write_real("Hats","Italian Hat",global.hat[51]);
	ini_write_real("Hats","Spanish Hat",global.hat[52]);
	ini_write_real("Hats","Magyar Hat",global.hat[53]);
	ini_write_real("Hats","Bosnian Hat",global.hat[54]);
	ini_write_real("Hats","Chinese Hat",global.hat[55]);
	ini_write_real("Hats","Ukraine Hat",global.hat[56]);
	ini_write_real("Hats","Macedonian Hat",global.hat[57]);
	ini_write_real("Hats","Chicken Hat",global.hat[58]);
	ini_write_real("Hats","Czech Hat",global.hat[59]);
	ini_write_real("Hats","Russian Hat",global.hat[60]);
	ini_write_real("Hats","Devil Hat",global.hat[61]);
	ini_write_real("Hats","Turkish Hat",global.hat[62])
	ini_write_real("Hats","Palestinian Hat",global.hat[63])
	ini_write_real("Hats","Slovenian Hat",global.hat[64])
	ini_write_real("Hats","Japanese Hat",global.hat[65])
	ini_write_real("Hats","Romanian Hat",global.hat[66])
	ini_write_real("Hats","Portuguese Hat",global.hat[67])
	
	ini_write_string("CustomHat","Custom Hat",global.CUSTOMhat);
	ini_close();
}
}