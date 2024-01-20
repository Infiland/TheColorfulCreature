function scr_saveendless() {
	
if global.cheats = 0 {
	
	var directory = game_save_id
	if global.moddedGameDir != "" { directory += "MODS//" + string(global.moddedGameDir) }
	directory += "//Save Files/"
	
	if (file_exists(directory + "Endless.sav")) file_delete(directory + "Endless.sav");
	ini_open(directory + "Endless.sav");
	ini_write_real("Endless","Highscore",global.endlesslevelhighscore);
	ini_write_real("Endless","Endless Highscore",global.newendlesslevelhighscore);
	ini_close();
	}
}