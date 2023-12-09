if locked = 1 { exit }
var level = asset_get_index("r_c" + string(global.calendaryear) + "lvl" + string(day + (28 * (global.calendarmonth-1))))
global.calendar = 1
calendarcheckmusic()
if room_exists(level) {
room_goto(level)
global.calendarweek = week
global.calendarday = day
scr_loadrewardscalendar()

rousr_dissonance_set_details("Playing Calendar - Year: " + string(global.calendaryear) + " | Day: " + string(global.calendarday +  (28 * (global.calendarmonth-1))))

loadhud()
} else {
//room_goto(r_templatelevelroom)
/*global.calendarroom = room_duplicate(r_templatelevelroom);
var directory = program_directory + "/Calendar//Level//r_c" + string(global.calendaryear) + "lvl" + string(day + (28 * (global.calendarmonth-1)))

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
	ini_close();
	}
	room_set_height(global.calendarroom,32*global.LELevelHeightBlocks)
	room_set_width(global.calendarroom,32*global.LELevelWidthBlocks)
room_goto(global.calendarroom)


	if global.LELevelHeightBlocks > 22 {
	if !instance_exists(o_smoothcamera) { instance_create(x,y,o_smoothcamera) }	
	}
	if global.LELevelWidthBlocks > 32 {
	if !instance_exists(o_smoothcamera) { instance_create(x,y,o_smoothcamera) }	
	}

	
	if global.LEStarRotation != 0 {
	var customstar = instance_create(x,y,o_customstarbackground)
	with customstar {
	customdirection = global.LEStarRotation
	}}
	scr_LEChangeScenery()

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
	}
	ds_map_destroy(_wrapper)
	}
*/
}