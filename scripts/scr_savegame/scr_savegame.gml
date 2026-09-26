function scr_savegame() {
    if ((platform_steam() && tcc_steam_get_app_id() == 1749610) || global.hardmode
        || global.challenges || global.endless || global.cheats || global.workshop
        || global.calendar || global.levelselect || global.dailylevel) return;
	var directory = directory_set("//Save Files/")

	var SavedRoom = room_get_name(room)

	if (scr_saved_room(SavedRoom) == -1) return;
	scr_save_begin(directory + "SaveFile.sav");
	ini_write_real("SaveFile Information","Deaths",global.deaths);
	ini_write_real("SaveFile Information","Coins",global.special);
	ini_write_real("SaveFile Information","Time",global.time);
	ini_write_real("SaveFile Information","Check Deposit",global.checkdeposit);
	ini_write_real("SaveFile Information","Boss One",global.boss1);
	ini_write_real("SaveFile Information","Boss Two",global.boss2);
	ini_write_real("SaveFile Information","Boss Three",global.boss3);
	ini_write_real("SaveFile Information","Boss Four",global.boss4);
	ini_write_real("SaveFile Information","Boss Five",global.boss5);
	ini_write_real("SaveFile Information","World 1 Time",global.world1time);
	ini_write_real("SaveFile Information","World 2 Time",global.world2time);
	ini_write_real("SaveFile Information","World 3 Time",global.world3time);
	ini_write_real("SaveFile Information","World 4 Time",global.world4time);
	ini_write_real("SaveFile Information","World 5 Time",global.world5time);
	ini_write_string("SaveFile Information","Level",SavedRoom);
	scr_save_finish(directory + "SaveFile.sav");

}
