function scr_loadworkshopmedals() {
if global.cheats = 0 {
	var directory = directory_set("/Custom/Workshop/Medals/" + string(level) + "/")
	
	if (file_exists(directory + "MedalData.sav")) {
	ini_open(directory + "MedalData.sav");
	time = ini_read_real("Medal Data","Time",9999999);
	requiredtime = ini_read_real("Medal Data","Required Time",999999);
	}
	else {
	}
	}

}
