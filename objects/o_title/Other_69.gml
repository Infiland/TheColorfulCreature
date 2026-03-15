// Online Multiplayer - Handle join requests from Steam overlay on title/menu screens
if (async_load[? "event_type"] == "lobby_join_requested") {
	if (global.onlinemultiplayersettings == 1 && steam_initialised()) {
		var _lobby_id = async_load[? "lobby_id"]
		show_debug_message("[NET] Join request received on menu for lobby: " + string(_lobby_id))
		
		// Initialize networking if needed
		if (!variable_global_exists("net_active")) {
			net_init()
		}
		
		// Leave any existing lobby
		if (global.net_active) {
			net_send_leave_info()
			steam_lobby_leave()
			ds_map_clear(global.net_players)
			global.net_active = false
			global.net_lobby_id = -1
			global.net_is_host = false
		}
		
		// Create the network manager if it doesn't exist
		if (!instance_exists(o_networkmanager)) {
			instance_create(0, 0, o_networkmanager)
		}
		
		// Defer the join (same pattern as the in-game handler)
		global.net_pending_join = _lobby_id
		global.net_connect_state = 2
		global.net_connect_timer = 0
		
		// Start the game - enter as level select
		scr_loadskins()
		global.levelselect = 1
		global.hardmode = 0
		global.challenges = 0
		global.endless = 0
		global.workshop = 0
		global.dailylevel = 0
		global.time = 0
		loadhud()
		audio_stop_sound(m_mainmenu)
		// Room will be set when lobby_joined fires and reads host's current_room
		room_goto(r_lvl1)
	}
	exit;
}

// Inventory pricing
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