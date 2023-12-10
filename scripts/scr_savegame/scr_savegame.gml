function scr_savegame() {
	if steam_get_app_id() != 1749610 {
	if room != r_leveleditor {
	if global.hardmode = 0 {
	if global.challenges = 0 {
	if global.endless = 0 {
	if global.cheats = 0 {
	if global.hardmode = 0 {
	if global.workshop = 0 {
	if global.calendar = 0 {
	if global.levelselect = 0 {
	if global.dailylevel = 0 {
	var directory = game_save_id + "/Save Files/"
	var SavedRoom = room_get_name(room)
	
	if SavedRoom != r_lvl1 {
	if (file_exists(directory + "SaveFile.sav")) file_delete(directory + "SaveFile.sav");
	ini_open(directory + "SaveFile.sav");
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
	ini_close();
	}}}}}}}}}}}}
}