// Early exit if event type doesn't match
if (async_load[? "event_type"] != "inventory_request_prices") exit;

// Early exit if handle doesn't match
if (async_load[? "success"])
{
    //show_debug_message("The currency being used is: " + async_load[? "currency"]);
	//Might use this later
	//var _price = steam_inventory_get_item_price(100);
	//steam_inventory_exchange_items()
	//show_debug_message("Found at one item that costs: " + string(_price));
}