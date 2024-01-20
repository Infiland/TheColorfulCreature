function scr_loadleveleditor() {
	
	instance_destroy(o_savedandloaded)
	box = instance_create(x,y,o_savedandloaded)
	
	var directory = directory_set("//LevelEditor Files//" + global.levelname + "/")
	if !directory_exists(directory) {
		with box { 
			//global.LEMode = 1
rousr_dissonance_set_details("Making a Level - " + global.levelname)
			image_index = 3 }
		exit 
		} else { with box { image_index = 1
			//global.LEMode = 2
rousr_dissonance_set_details("Playing a Level - " + global.levelname)
			}}
	
	global.LELevelPreviousWidthBlocks = global.LELevelWidthBlocks
	global.LELevelPreviousHeightBlocks = global.LELevelHeightBlocks
	
	if (file_exists(directory + "OtherLevelEditor.sav")) {
	ini_open(directory + "OtherLevelEditor.sav");
	global.leveleditorstring = ini_read_string("Other LE","Text","");
	global.leveleditormusic = ini_read_string("Other LE","Music","");
	global.leveleditorversion = ini_read_string("Other LE","Version","");
	global.levelname = ini_read_string("Other LE","Name","");
	global.defaultcolorLE = ini_read_real("Other LE","Default Starting Color",0);
	global.LEBackground = ini_read_real("Other LE","Background",0);
	global.LEStarRotation = ini_read_real("Other LE","Star Rotation",0);
	global.LEDiamondMedalTime = ini_read_real("Other LE","Diamond Medal Time",35);
	global.LELevelWidthBlocks = ini_read_real("Other LE","Level Width Blocks",32);
	global.LELevelHeightBlocks = ini_read_real("Other LE","Level Height Blocks",22);
	global.LEBlockStyle = ini_read_real("Other LE","Level Block Style",0);
	global.LEStarStyle = ini_read_real("Other LE","Level Star Style",0);
	global.LEFog = ini_read_real("Other LE","Level Fog",0);
	global.Publish_ID = ini_read_real("Other LE","Publish ID",0);
	global.workshoplevelversion = ini_read_real("Other LE","Workshop Level Version",0);
	ini_close();
	}
	
	/*room_set_height(r_leveleditor,32*global.LELevelHeightBlocks)
	room_set_width(r_leveleditor,32*global.LELevelWidthBlocks)
	room_restart()*/
	
	/*instance_destroy(o_smoothcamera)
	if global.LELevelWidthBlocks <= 32 {global.LELevelWidthBlocks = 32} else {
		room_set_width(r_leveleditor,32*global.LELevelWidthBlocks)
		if !instance_exists(o_smoothcamera) {instance_create(x,y,o_smoothcamera)}
	}
		if global.LELevelHeightBlocks <= 22 {global.LELevelHeightBlocks = 22} else {
	
		room_set_height(r_leveleditor,32*global.LELevelHeightBlocks)
		if !instance_exists(o_smoothcamera) {instance_create(x,y,o_smoothcamera)}
	}
	
	if global.LELevelPreviousHeightBlocks != global.LELevelHeightBlocks {
		room_set_height(r_leveleditor,32*global.LELevelHeightBlocks)
		room_set_width(r_leveleditor,32*global.LELevelWidthBlocks)
	room_restart()
	scr_loadleveleditor()
	}
	if global.LELevelPreviousWidthBlocks != global.LELevelWidthBlocks {
	room_set_height(r_leveleditor,32*global.LELevelHeightBlocks)
	room_set_width(r_leveleditor,32*global.LELevelWidthBlocks)
	room_restart()
	scr_loadleveleditor()
	}*/

	
	layer = layer_create(-100)
	with(o_leveleditorloadplacement) instance_destroy();
	if file_exists(directory + "LevelEditor.sav") {
	var _wrapper = LoadJSONFromFile(directory + "LevelEditor.sav");
	var _list = _wrapper[? "ROOT"]; //var list = ds_map_find_value(_wrapper,"ROOT")
	for (var i=0;i < ds_list_size(_list);i++) {
	var _map = _list[| i] //var _map = ds_list_find_value(_list,i)
	var _obj = _map[? "obj"];
	with(instance_create_layer(0,0,layer,asset_get_index(_obj))) {
	x = _map[? "x"]
	y = _map[? "y"]
	if global.leveleditorversion > 1 {
	image_index = _map[? "imageindex"]
	image_xscale = _map[? "xscale"]
	image_yscale = _map[? "yscale"]
	}
	}
	/*
	with(instance_create_layer(0,0,layer,asset_get_index(o_shooter))) {
	originaltimer = _map[? "o_timer"]
	}*/
	}
	ds_map_destroy(_wrapper)
	}


}