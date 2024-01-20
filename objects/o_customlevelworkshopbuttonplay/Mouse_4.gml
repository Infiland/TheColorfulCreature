if mPubFileId != 0 {
if mBanned = false {
global.deaths = 0
global.time = 0
global.Publish_ID = level
global.levelname = mTitle
global.workshopfolder = mPath


global.workshopfolder = string_replace_all(global.workshopfolder,"\\","/")

var directory = directory_set(global.workshopfolder + "/",1)
directory = string_replace_all(directory,"\\","/")

	if (file_exists(directory + "OtherLevelEditor.sav")) {
	ini_open(directory + "OtherLevelEditor.sav");
	global.LELevelWidthBlocks = ini_read_real("Other LE","Level Width Blocks",32);
	global.LELevelHeightBlocks = ini_read_real("Other LE","Level Height Blocks",22);
	}
	
room_set_width(r_customlevelworkshop,global.LELevelWidthBlocks*32)
room_set_height(r_customlevelworkshop,64+(global.LELevelHeightBlocks*32))

alarm[1] = 1
}}