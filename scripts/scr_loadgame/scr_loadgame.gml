function scr_loadgame() {
	
	var directory = game_save_id
	if global.moddedGameDir != "" { directory += "MODS//" + string(global.moddedGameDir) }
	directory += "//Save Files/"
	
	if (file_exists(directory + "SaveFile.sav")) {
	ini_open(directory + "SaveFile.sav");
	var LoadedRoom = ini_read_string("SaveFile Information","Level","r_lvl1")
	global.deaths = ini_read_real("SaveFile Information","Deaths",0);
	global.time = ini_read_real("SaveFile Information","Time",0);
	global.special = ini_read_real("SaveFile Information","Coins",0);
	global.checkdeposit = ini_read_real("SaveFile Information","Check Deposit",false);
	global.boss1 = ini_read_real("SaveFile Information","Boss One",0);
	global.boss2 = ini_read_real("SaveFile Information","Boss Two",0);
	global.boss3 = ini_read_real("SaveFile Information","Boss Three",0);
	global.boss4 = ini_read_real("SaveFile Information","Boss Four",0);
	global.boss5 = ini_read_real("SaveFile Information","Boss Five",0);
	global.world1time = ini_read_real("SaveFile Information","World 1 Time",0);
	global.world2time = ini_read_real("SaveFile Information","World 2 Time",0);
	global.world3time = ini_read_real("SaveFile Information","World 3 Time",0);
	global.world4time = ini_read_real("SaveFile Information","World 4 Time",0);
	global.world5time = ini_read_real("SaveFile Information","World 5 Time",0);
	ini_close();

	room_goto(asset_get_index(LoadedRoom));
	global.hatmerchantdiscount = 1
	if LoadedRoom != r_lvl1 {
	loadhud()
	}
	} else {
	
	}


}
