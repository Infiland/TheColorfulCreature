// Early exit if event type doesn't match
if (async_load[? "event_type"] != "inventory_result_ready") exit;

// Early exit if handle doesn't match
if (async_load[? "handle"] != handle) exit;

// Early exit if handle doesn't match
if (async_load[? "success"])
{
    var _items = steam_inventory_result_get_items(handle);

    var _status = steam_inventory_result_get_status(handle);
    var _timestamp = steam_inventory_result_get_unix_timestamp(handle);
	
	
	//show_debug_message(_items)
	
	array_delete(global.itemdef,0,40000)
	global.itemdef = array_create(5000)
    for (var i = 0; i < array_length(_items); i++)
    {
        // It's also possible to get properties from each item using
        //prop1 = steam_inventory_result_get_item_property(handle, i, "property_name1");
        // prop2 = steam_inventory_result_get_item_property(handle, i, "property_name2");
		var _struct = _items[i];
		var _item_id = _struct.item_id;
		array_insert(global.itemdef,_struct.item_def,1)
		//show_debug_message(_struct)
    }
	//show_debug_message(global.itemdef)
}

// Don't forget to clean the unused handle
steam_inventory_result_destroy(handle);
handle = undefined;