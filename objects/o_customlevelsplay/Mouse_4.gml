if instance_exists(o_customlevelworkshopbuttonplay) { exit }
if global.steam_api = true {
if !instance_exists(o_showsubscribedlevels) {
instance_create(x,y,o_showsubscribedlevels)	
}

steam_list = ds_list_create();
steam_ugc_get_subscribed_items(steam_list);

var steamlevel
for (var i = 0; i < ds_list_size(steam_list); i++) {

  var file_id = steam_list[| i];
  var file_info = ds_map_create();
  steam_ugc_get_item_install_info(file_id, file_info);
  var path_to_file = file_info[? "folder"];
	
	
steamlevel = ds_list_find_value(steam_list,i)
var button = instance_create((room_width/2)-100,150 + (i* 95), o_customlevelworkshopbuttonplay)
with(button) {
level = steamlevel
mPath = path_to_file
}
if i > 5 {
global.customlevelsscrollmax += 95
}
}

}
//string_replace(string(global.workshopfolder),"\"","/")


//for (i=0; i <ds_list_size(steam_list); i++) {