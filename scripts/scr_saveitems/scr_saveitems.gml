function scr_saveitems() {
if global.cheats = 0 {
	var directory = game_save_id
	if global.moddedGameDir != "" { directory += "MODS//" + string(global.moddedGameDir) }
	directory += "//Save Files/"
	if (file_exists(directory + "Items.sav")) file_delete(directory + "Items.sav");
	ini_open(directory +"Items.sav");
	//Hats
	ini_write_real("Items","Selected Item",global.itemselected);
	ini_write_real("Items","Paintbrush Item",global.item001);
	ini_write_real("Items","Flower Item",global.item002);
	ini_write_real("Items","Shield Item",global.item003);
	ini_close();

}
}