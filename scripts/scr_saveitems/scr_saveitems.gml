function scr_saveitems() {
if global.cheats = 0 {
	
	var directory = directory_set("//Save Files/")
	
	if (file_exists(directory + "Items.sav")) file_delete(directory + "Items.sav");
	ini_open(directory +"Items.sav");
	//Hats
	ini_write_real("Items","Selected Item",global.itemselected);
	ini_write_real("Skins","Item Name Object Selected",global.itemnameobjectselected)
	ini_write_real("Items","Paintbrush Item",global.item[1]);
	ini_write_real("Items","Flower Item",global.item[2]);
	ini_write_real("Items","Shield Item",global.item[3]);
	ini_close();

}
}