function scr_loadgame() {

	var directory = directory_set("//Save Files/")

	scr_save_recover(directory + "SaveFile.sav");
	if (file_exists(directory + "SaveFile.sav")) {
	ini_open(directory + "SaveFile.sav");
	var LoadedRoom = ini_read_string("SaveFile Information","Level","r_lvl1")
	var _room = scr_saved_room(LoadedRoom);
	if (_room == -1) {
		ini_close();
		show_message_async("This save contains an invalid level. Your save has been kept.");
		return false;
	}
	global.deaths = scr_save_number("SaveFile Information","Deaths",0);
	global.time = scr_save_number("SaveFile Information","Time",0);
	global.special = scr_save_number("SaveFile Information","Coins",0);
	global.checkdeposit = scr_save_number("SaveFile Information","Check Deposit",false);
	global.boss1 = scr_save_number("SaveFile Information","Boss One",0);
	global.boss2 = scr_save_number("SaveFile Information","Boss Two",0);
	global.boss3 = scr_save_number("SaveFile Information","Boss Three",0);
	global.boss4 = scr_save_number("SaveFile Information","Boss Four",0);
	global.boss5 = scr_save_number("SaveFile Information","Boss Five",0);
	global.world1time = scr_save_number("SaveFile Information","World 1 Time",0);
	global.world2time = scr_save_number("SaveFile Information","World 2 Time",0);
	global.world3time = scr_save_number("SaveFile Information","World 3 Time",0);
	global.world4time = scr_save_number("SaveFile Information","World 4 Time",0);
	global.world5time = scr_save_number("SaveFile Information","World 5 Time",0);
	ini_close();

	room_goto(_room);
	global.hatmerchantdiscount = 1
	if _room != r_lvl1 {
	loadhud()
	}

	// Online Multiplayer - Spawn network manager when loading a game
	if (global.onlinemultiplayersettings == 1 && tcc_steam_initialised()) {
		if (!instance_exists(o_networkmanager)) {
			instance_create(0, 0, o_networkmanager)
		}
	}
	} else {

	}


}
