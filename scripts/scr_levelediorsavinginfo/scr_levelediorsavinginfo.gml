function scr_levelediorsavinginfo() {
	var _root_list
	var _map = ds_map_create();
	ds_list_add(_root_list,_map);
	ds_list_mark_as_map(_root_list,ds_list_size(_root_list)-1);
	var _obj = object_get_name(object_index)
	ds_map_add(_map,"obj",_obj);
	ds_map_add(_map,"y",y);
	ds_map_add(_map,"x",x);


}
