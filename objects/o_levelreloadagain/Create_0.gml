var directory = directory_set("/LevelEditor Files//" + global.levelname + "/")
	if (file_exists(directory + "OtherLevelEditor.sav")) {
	ini_open(directory + "OtherLevelEditor.sav");
	global.LELevelWidthBlocks = ini_read_real("Other LE","Level Width Blocks",32);
	global.LELevelHeightBlocks = ini_read_real("Other LE","Level Height Blocks",22);
	}
	
room_set_width(r_leveleditor,global.LELevelWidthBlocks*32)
room_set_height(r_leveleditor,64+(global.LELevelHeightBlocks*32))

room_restart()
	
alarm[0] = 1