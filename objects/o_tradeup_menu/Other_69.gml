// Handle Steam inventory exchange result
if (async_load[? "event_type"] != "inventory_result_ready") exit;
if (trade_handle = undefined) exit;
if (async_load[? "handle"] != trade_handle) exit;

if (async_load[? "success"]) {
	// Trade succeeded - refresh inventory and rebuild list
	steam_inventory_result_destroy(trade_handle);
	trade_handle = undefined;
	trade_in_progress = false;

	// Refresh the full inventory
	instance_create(0, 0, o_getallinventoryitems);

	// Show success popup
	global.popup_config = {
		title: loc("TRADE_UP"),
		message: "Trade successful!",
		mode: 0,
		ok_text: "OK",
		cb_ok: undefined
	}
	instance_create(0, 0, o_popup)

	// Rebuild eligible entries after a short delay (inventory needs to reload)
	alarm[0] = 60;
} else {
	// Trade failed
	steam_inventory_result_destroy(trade_handle);
	trade_handle = undefined;
	trade_in_progress = false;

	global.popup_config = {
		title: loc("TRADE_UP"),
		message: "Trade failed. Please try again.",
		mode: 0,
		ok_text: "OK",
		cb_ok: undefined
	}
	instance_create(0, 0, o_popup)
}