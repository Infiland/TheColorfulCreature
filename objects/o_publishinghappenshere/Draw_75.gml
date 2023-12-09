draw_set_alpha(0.5)
draw_rectangle_color(0,0,room_width,room_height,c_black,c_black,c_black,c_black,false)
draw_set_font(global.gamemodefont)
draw_set_alpha(1)
draw_set_halign(fa_center)

		/*var uploadMap = ds_map_create();
steam_ugc_get_item_update_progress(new_map, uploadMap);
var statusCode = uploadMap[? "status_code"];
var status = uploadMap[? "status_string"];
var processed = uploadMap[? "bytes_processed"];
var total = uploadMap[? "bytes_total"];
draw_text(16, 500, "Upload info for item:" + string(new_map));
draw_text(16, 515, "status code:" + string(statusCode));
draw_text(16, 530, "status:" + string(status));
draw_text(16, 545, "bytes processed:" +string(processed));
draw_text(16, 560, "bytes total:" + string( total));
ds_map_destroy(uploadMap);*/

switch(result) {
default: draw_text(512,250,"Uploading...") break;
case(0.1): draw_text(512,250,"Setting Title") break;
case(0.2): draw_text(512,250,"Setting Image") break;
case(0.3): draw_text(512,250,"Setting Description") break;
case(0.4): draw_text(512,250,"Setting the Level to be public!") break;
case(0.5): draw_text(512,250,"Uploading Level") break;
case(0.6): draw_text(512,250,"Setting Tags") break;
case(0.7): draw_text(512,250,"Finishing up!") break;
case(1):  if updated = 0 {
draw_text(512,250,loc(559)) } else {  draw_text(room_width/2,250,loc(621)) }
draw_text(512,310,"Publish ID: " + string(global.Publish_ID))
draw_text(512,410,"The game is likely to crash after this point. Please stay in the game\nfor a minute, so no corruptions happen!")
timer -= 1
break;
case(2): draw_text(512,250,"Failed cuz you didn't accept the\nLegal Agreement!")
timer -= 1
break;
case(3): draw_text(512,250,loc(588))
timer -= 1
break;
case(4): draw_text(512,250,loc(589))
timer -= 1
break;
case(5): draw_text(512,250,loc(590))
timer -= 1
break;
case(6): draw_text(512,250,"Not yet son")
timer -= 1
break;
}
draw_set_halign(fa_left)

draw_set_color(c_white)
draw_rectangle(0,740,timer,770,false)

if timer < 0 { 
	if result = 1 {
	global.workshoplevelversion += 1
	var directory = working_directory + "/LevelEditor Files/" + "/" + global.levelname + "/"
	if !directory_exists(directory) {directory_create(directory)}

	//Level Editor Version
	if (file_exists(directory + "OtherLevelEditor.sav")) file_delete(directory + "OtherLevelEditor.sav");
	ini_open(directory + "OtherLevelEditor.sav");
		if (file_exists(directory + "OtherLevelEditor.sav")) file_delete(directory + "OtherLevelEditor.sav");
	ini_open(directory + "OtherLevelEditor.sav");
	ini_write_string("Other LE","Text",global.leveleditorstring);
	ini_write_string("Other LE","Music",global.leveleditormusic);
	ini_write_string("Other LE","Version",global.leveleditorversion);
	ini_write_string("Other LE","Name",global.levelname);
	ini_write_real("Other LE","Default Starting Color",global.defaultcolorLE)
	ini_write_real("Other LE","Background",global.LEBackground)
	ini_write_real("Other LE","Star Rotation",global.LEStarRotation)
	ini_write_real("Other LE","Diamond Medal Time",global.LEDiamondMedalTime)
	ini_write_real("Other LE","Level Width Blocks",global.LELevelWidthBlocks)
	ini_write_real("Other LE","Level Height Blocks",global.LELevelHeightBlocks)
	ini_write_real("Other LE","Publish ID",global.Publish_ID)
	ini_write_real("Other LE","Workshop Level Version",global.workshoplevelversion)
	ini_close();
	ini_close();
	}
	if !instance_exists(o_restartgameLE) {
var restart = instance_create(416,512,o_restartgameLE)
with restart {
	x = 416
	y = 512
}}
	}