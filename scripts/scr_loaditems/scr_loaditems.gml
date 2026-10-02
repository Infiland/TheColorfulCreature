function scr_loaditems(_directory = undefined) {
if global.cheats = 0 {

	cosmetics_defaults();
	var directory = is_undefined(_directory) ? directory_set("//Save Files/") : _directory;
	scr_save_recover(directory + "Items.sav");

	if (file_exists(directory + "Items.sav")) {
	ini_open(directory + "Items.sav");
	global.itemselected = ini_read_real("Items","Selected Item",0)
	global.itemnameobjectselected = ini_read_real("Items","Item Name Object Selected",ini_read_real("Skins","Item Name Object Selected",o_unequipeditembutton))
	global.item[1] = ini_read_real("Items","Paintbrush Item",0)
	global.item[2] = ini_read_real("Items","Flower Item",0)
	global.item[3] = ini_read_real("Items","Shield Item",0)
	global.CUSTOMitem = ini_read_string("CustomItem","Custom Item","");
	global.itemselected = settings_number(global.itemselected, 0, 0, 3);
	if (!cosmetics_valid_name(global.CUSTOMitem)) global.CUSTOMitem = "";
	ini_close();
	}
	else {
	}

	}

}
