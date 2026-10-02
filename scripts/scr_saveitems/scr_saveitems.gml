function scr_saveitems(_directory = undefined) {
if global.cheats = 0 {
	
	cosmetics_defaults();
	var directory = is_undefined(_directory) ? directory_set("//Save Files/") : _directory;
	if (!directory_exists(directory)) directory_create(directory);
	
	scr_save_begin(directory + "Items.sav");
	//Items
	ini_write_real("Items","Selected Item",global.itemselected);
	ini_write_real("Items","Item Name Object Selected",global.itemnameobjectselected)
	ini_write_real("Items","Paintbrush Item",global.item[1]);
	ini_write_real("Items","Flower Item",global.item[2]);
	ini_write_real("Items","Shield Item",global.item[3]);
	ini_write_string("CustomItem","Custom Item",global.CUSTOMitem);
	return scr_save_finish(directory + "Items.sav");

}
}