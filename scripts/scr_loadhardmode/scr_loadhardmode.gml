function scr_loadhardmode() {
if global.cheats = 0 {
	var directory = working_directory + "/Save Files/"
	if (file_exists(directory + "Hardmode.sav")) {
	ini_open(directory + "Hardmode.sav");
	global.hardmodeunlock = ini_read_real("Hardmode","HardmodeUnlock",0);
	}
	else {
	}
	}

}
