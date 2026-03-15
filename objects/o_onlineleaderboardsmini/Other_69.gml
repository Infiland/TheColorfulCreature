if global.hardmode = 1 { instance_destroy() 
exit;	
}

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
			
			var entry_user_id = noone;
			if ds_map_exists(entry, "userID") {
				entry_user_id = ds_map_find_value(entry, "userID");
			} else if ds_map_exists(entry, "steamid") {
				entry_user_id = ds_map_find_value(entry, "steamid");
			}
			steam_userid[i] = entry_user_id;
			
			if entry_user_id != noone && entry_user_id != 0 {
				var user_key = string(entry_user_id);
				if (!ds_map_exists(avatar_sprites, user_key)) {
					var img = steam_get_user_avatar(real(entry_user_id), avatar_request_size);
					if (img > 0) {
						var spr = steam_image_create_sprite(img);
						ds_map_set(avatar_sprites, user_key, spr);
					} else if (img == 0) {
						ds_map_set(avatar_sprites, user_key, -2);
					} else {
						ds_map_set(avatar_sprites, user_key, -1);
					}
				}
			}
        }
    }
    ds_map_destroy(map)
}

if (async_load[?"event_type"] != "avatar_image_loaded") exit;

var _success = async_load[?"success"];
if (_success == 1) {
	var _user_id = async_load[?"user_id"];
	var _image = async_load[?"image"];
	if (_image > 0) {
		var _user_key = string(_user_id);
		if (ds_map_exists(avatar_sprites, _user_key)) {
			var _old = ds_map_find_value(avatar_sprites, _user_key);
			if (sprite_exists(_old)) { sprite_delete(_old) }
		}
		var _spr = steam_image_create_sprite(_image);
		ds_map_set(avatar_sprites, _user_key, _spr);
	}
} else {
	show_debug_message("Failed to get user avatar");
}
