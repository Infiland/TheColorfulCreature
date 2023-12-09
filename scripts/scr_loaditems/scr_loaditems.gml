function scr_loaditems() {
if global.cheats = 0 {
	var directory = working_directory + "/Save Files/"
	if (file_exists(directory + "Items.sav")) {
	ini_open(directory + "Items.sav");
	global.itemselected = ini_read_real("Items","Selected Item",0)
	global.item001 = ini_read_real("Items","Paintbrush Item",0)
	global.item002 = ini_read_real("Items","Flower Item",0)
	global.item003 = ini_read_real("Items","Shield Item",0)
	}
	else {
	}
	
	}

}