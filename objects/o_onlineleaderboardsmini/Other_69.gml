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
        }
    }
    ds_map_destroy(map)
}