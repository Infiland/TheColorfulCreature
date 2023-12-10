	var directory = game_save_id + "/Save Files/"
		if (file_exists(directory + "Stats.sav")) file_delete(directory + "Stats.sav");
	scr_reloadstats()
room_restart()
scr_loadstats()