var async_id = ds_map_find_value(async_load, "id");
if async_id == score_get
{
    var entries = ds_map_find_value(async_load, "entries");
    var map = json_decode(entries);
    if ds_map_exists(map, "default")
    {
        ds_map_destroy(map);
        exit;
    }
    else
    {
        var list = ds_map_find_value(map, "entries");
        var len = ds_list_size(list);
        var entry;
        for(var i = 0; i < len; i++;)
        {
            entry = ds_list_find_value(list, i );
            steam_name[i] = ds_map_find_value(entry, "name");
            steam_score[i] = ds_map_find_value(entry, "score");
            steam_rank[i] = ds_map_find_value(entry, "rank");
        }
    }
    ds_map_destroy(map)
}

if (async_load[?"event_type"] != "avatar_image_loaded") exit;

var _success = async_load[?"success"];
if (_success == 1) {
		if userID != noone {
var av = steam_get_user_avatar(real(userID), steam_user_avatar_size_small);
if (av != -1) 
	avatar_sprite = steam_image_create_sprite(av);
else 
	avatar_sprite = -1;
}
} else {
    show_debug_message("Failed to get user avatar");
}