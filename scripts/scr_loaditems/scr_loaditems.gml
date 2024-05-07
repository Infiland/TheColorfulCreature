function scr_loaditems() {
if global.cheats = 0 {
	
	var directory = directory_set("//Save Files/")
	
	if (file_exists(directory + "Items.sav")) {
	ini_open(directory + "Items.sav");
	global.itemselected = ini_read_real("Items","Selected Item",0)
	global.itemnameobjectselected = ini_read_real("Items","Item Name Object Selected",o_unequipeditembutton)
	global.item[1] = ini_read_real("Items","Paintbrush Item",0)
	global.item[2] = ini_read_real("Items","Flower Item",0)
	global.item[3] = ini_read_real("Items","Shield Item",0)
	}
	else {
	}
	
	}

}