score_get = steam_download_scores("Tutorial Challenge Time", 1, rlen);
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
         if (ds_map_exists(entry, "data"))
            {
            var data = ds_map_find_value(entry, "data");
            var buffId = buffer_base64_decode(data);
          var message = buffer_read(buffId, buffer_string);
            show_debug_message( " -- attached message: " + string(message));
            buffer_delete(buffId);
            }
         ds_map_destroy(entry);
       }
      ds_list_destroy(list)
      }
   ds_map_destroy(map)
   }