function scr_savehardmode() {
if global.cheats = 0 {
	
	var directory = game_save_id
	if global.moddedGameDir != "" { directory += "MODS//" + string(global.moddedGameDir) }
	directory += "//Save Files/"
	
	if (file_exists(directory + "Hardmode.sav")) file_delete(directory + "Hardmode.sav");
	ini_open(directory + "Hardmode.sav");
	ini_write_real("Hardmode","HardmodeUnlock",global.hardmodeunlock);
	ini_close();
	}

}
