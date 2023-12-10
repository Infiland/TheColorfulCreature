function scr_loadendless() {
if global.cheats = 0 {
	var directory = game_save_id + "/Save Files/"
	if (file_exists(directory + "Endless.sav")) {
	ini_open(directory + "Endless.sav");
	global.endlesslevelhighscore = ini_read_real("Endless","Highscore",0)
	global.newendlesslevelhighscore = ini_read_real("Endless","Endless Highscore",0)
	}
	else {
	}
	}

}
