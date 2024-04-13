/*var agreement = async_load[? "legal_agreement_required"];
if agreement == false {
result = 2
exit;
}*/

if timer2 < 0 { exit; }

if steam_is_user_logged_on() = false {
result = 3
}
var directory = directory_set("/LevelEditor Files//" + global.levelname + "//thumb.jpg")
if !directory_exists(directory) {
result = 5
}

if global.Publish_ID = 0 {
var event_id = async_load[? "id"];
if event_id == new_item
    {
    var type = async_load[? "event_type"];
    if type == "ugc_create_item"
        {
        global.Publish_ID = async_load[? "published_file_id"];
        }
    }
} else { updated = 1 }
	
var updateHandle = steam_ugc_start_item_update(global.appid, global.Publish_ID);
result = 0.1
steam_ugc_set_item_title(updateHandle, global.levelname);
result = 0.2
steam_ugc_set_item_description( updateHandle, global.leveleditorstring);
result = 0.3
steam_ugc_set_item_visibility(updateHandle, ugc_visibility_public);
result = 0.4
var tagArray,i;
i = 0
tagArray[0] = "Levels";
i++
if instance_exists(o_spike) || instance_exists(o_spikeleft) || instance_exists(o_spikeright) || instance_exists(o_spiketop) {
tagArray[i] = "Spikes";
i++
}
if instance_exists(o_invspike) || instance_exists(o_invspikeleft) || instance_exists(o_invspikeright) || instance_exists(o_invspiketop) {
tagArray[i] = "Invisible Spikes";
i++
}
if instance_exists(o_shooter) || instance_exists(o_shooterright) {
tagArray[i] = "Cannons";
i++
}
if instance_exists(o_gravity01LE) || instance_exists(o_gravity05LE) || instance_exists(o_gravity15LE) || instance_exists(o_gravity25LE) || instance_exists(o_zerogravityLE) || instance_exists(o_gravitylimit01) || instance_exists(o_gravitylimit05) || instance_exists(o_gravitylimit15) || instance_exists(o_gravitylimit25) || instance_exists(o_zerogravitylimit) {
tagArray[i] = "Gravity";
i++
}
if instance_exists(o_speed5LE) || instance_exists(o_speed7LE) || instance_exists(o_speed10LE) || instance_exists(o_speed15LE) || instance_exists(o_speedlimit5) || instance_exists(o_speedlimit7) || instance_exists(o_speedlimit10) || instance_exists(o_speedlimit15) {
tagArray[i] = "Speed";
i++
}
if instance_exists(o_portalpurpleopen) || instance_exists(o_portalpurpleclosed) {
tagArray[i] = "Portals";
i++
}
if instance_exists(o_fog) {
tagArray[i] = "Fog";
i++
}
if instance_exists(o_enemyplayerLE) {
tagArray[i] = "Troops";
i++
}
if instance_exists(o_onewaydownblock) || instance_exists(o_onewayupblock) || instance_exists(o_onewayleftblock) || instance_exists(o_onewayrightblock) {
tagArray[i] = "One Way Blocks";
i++
}
if instance_exists(o_rocketlauncher) || instance_exists(o_rocketlauncherright) {
tagArray[i] = "Rocket Cannons";
i++
}
if instance_exists(o_water) || instance_exists(o_lava) {
tagArray[i] = "Liquids";
i++
}
if instance_exists(o_spikemovingdownupLE) || instance_exists(o_spikemovingrightleftLE) || instance_exists(o_spikemovingleftrightLE) || instance_exists(o_spikemovingupdownLE) {
tagArray[i] = "Vertical Spikes";
i++
}
if instance_exists(o_HspikemovingupLE) || instance_exists(o_HspikemovingdownLE) || instance_exists(o_HspikemovingleftLE) || instance_exists(o_HspikemovingrightLE) {
tagArray[i] = "Horizontal Spikes";
i++
}
if global.LELevelWidthBlocks > 40 || global.LELevelWidthBlocks > 40 {
tagArray[i] = "Big Level";
i++
}


steam_ugc_set_item_tags(updateHandle, tagArray);
result = 0.5
steam_ugc_set_item_preview(updateHandle, image);
result = 0.6
var directory = directory_set("/LevelEditor Files//" + global.levelname + "/")
steam_ugc_set_item_content(updateHandle, directory);
requestId = steam_ugc_submit_item_update(updateHandle, "Version 1." + string(global.workshoplevelversion));

var upload = async_load[? "result"];
if upload == ugc_result_success {
result = 1
timer = 1000
if global.skin[42] = 0 {
global.skin[42] = 1
scr_saveskins()
}


} else { result = 4 }




/*var app_id = steam_get_app_id();
var new_item = steam_ugc_create_item(app_id, ugc_filetype_community);

if steam_is_user_logged_on() {
var event_id = async_load[? "id"];
if(event_id == new_item){
    var type = async_load[? "event_type"];
	if(type == "ugc_create_item"){
        publishID = async_load[? "published_file_id"];
		}}
		
		//var app_id = "1651680"
        new_map = steam_ugc_start_item_update(app_id, publishID);
		result = 0.1
        steam_ugc_set_item_title(new_map, global.levelname);
		result = 0.2
		steam_ugc_set_item_preview(new_map, image);
		result = 0.3
        steam_ugc_set_item_description(new_map, "A Level in The Colorful Creature!");
		result = 0.4
        steam_ugc_set_item_visibility(new_map, ugc_visibility_public);
		result = 0.5
		var directory = working_directory + "/LevelEditor Files/" + "/" + global.levelname + "/"
        steam_ugc_set_item_content(new_map, directory);
		result = 0.6
        var tags;
       tags[0] = "level";
        steam_ugc_set_item_tags(new_map,tags);
		result = 0.7
		requestID = steam_ugc_submit_item_update(new_map, "1.0")
		

		//if(type == "result") { result = 1 } else { result = 4 }
		result = 1
		show_debug_message("send request: "+string(requestID));
} else { result = 3 }*/