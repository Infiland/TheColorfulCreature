/// Steam owns the inventory. Local trade state never grants or removes items.
function tradeup_defaults() {
	if (!variable_global_exists("tradeup_state")) global.tradeup_state = {
		phase:"idle", ready:false, inventory_handle:-1, trade_handle:-1,
		revision:0, inventory_started:0, trade_started:0, message:"", outcome:""
	};
}

function tradeup_integer(_value, _minimum, _maximum) {
	return (is_real(_value) || is_int64(_value)) && !is_nan(_value) && !is_infinity(_value)
		&& _value == floor(_value) && _value >= _minimum && _value <= _maximum;
}

function tradeup_item_id_valid(_value) {
	// Native inventory instance IDs are int64; do not round them through a double.
	if (is_int64(_value)) return _value > 0;
	return tradeup_integer(_value, 1, 9007199254740991);
}

function tradeup_handle_valid(_handle) {
	return tradeup_integer(_handle, 0, 2147483647);
}

/// Sum distinct stacks and reject ambiguous duplicate IDs before publishing a snapshot.
function tradeup_inventory_snapshot(_items) {
	var _bad = {ok:false};
	if (!is_array(_items)) return _bad;
	var _counts = array_create(5000, 0), _stacks = array_create(5000, undefined), _seen = {};
	for (var _i = 0; _i < array_length(_items); ++_i) {
		var _entry = _items[_i];
		if (!is_struct(_entry) || !variable_struct_exists(_entry,"item_id")
			|| !variable_struct_exists(_entry,"item_def") || !variable_struct_exists(_entry,"quantity")) return _bad;
		if (!tradeup_item_id_valid(_entry.item_id) || !tradeup_integer(_entry.item_def, 0, 2147483647)
			|| !tradeup_integer(_entry.quantity, 0, 65535)) return _bad;
		var _flags = variable_struct_exists(_entry,"flags") ? _entry.flags : 0;
		if (!tradeup_integer(_flags, 0, 65535)) return _bad;
		var _key = string(_entry.item_id);
		if (variable_struct_exists(_seen,_key)) return _bad;
		variable_struct_set(_seen,_key,true);
		// Steam marks removed/consumed entries with bits 8/9. They are not spendable.
		if ((_flags & 768) != 0 || _entry.quantity == 0 || _entry.item_def >= 5000) continue;
		var _def = _entry.item_def;
		_counts[_def] += _entry.quantity;
		if (!is_array(_stacks[_def])) _stacks[_def] = [];
		array_push(_stacks[_def], {item_id:int64(_entry.item_id), quantity:_entry.quantity});
	}
	return {ok:true, counts:_counts, stacks:_stacks};
}

/// Pure recipe builder: exactly five of one definition, one of its next tier.
function tradeup_plan(_skin, _tier, _entries) {
	if (!tradeup_integer(_skin,1,50) || !tradeup_integer(_tier,1,4) || !is_array(_entries)) return undefined;
	var _destroy = [], _remaining = 5, _seen = {};
	for (var _i = 0; _i < array_length(_entries); ++_i) {
		var _entry = _entries[_i];
		if (!is_struct(_entry) || !variable_struct_exists(_entry,"item_id") || !variable_struct_exists(_entry,"quantity")
			|| !tradeup_item_id_valid(_entry.item_id) || !tradeup_integer(_entry.quantity,1,65535)) return undefined;
		var _key = string(_entry.item_id);
		if (variable_struct_exists(_seen,_key)) return undefined;
		variable_struct_set(_seen,_key,true);
		if (_remaining > 0) {
			var _quantity = min(_remaining,_entry.quantity);
			array_push(_destroy,{item_id:int64(_entry.item_id),quantity:_quantity});
			_remaining -= _quantity;
		}
	}
	if (_remaining != 0) return undefined;
	return {skin:_skin, tier:_tier, source_def:scr_get_item_def_for_tier(_skin,_tier),
		create:[{item_def:scr_get_item_def_for_tier(_skin,_tier+1),quantity:1}], destroy:_destroy};
}

function tradeup_result_matches(_event,_handle) {
	return tradeup_handle_valid(_handle) && (is_real(_event) || is_handle(_event)) && ds_exists(_event,ds_type_map)
		&& ds_map_exists(_event,"event_type") && _event[? "event_type"] == "inventory_result_ready"
		&& ds_map_exists(_event,"handle") && _event[? "handle"] == _handle;
}

function tradeup_request_inventory() {
	tradeup_defaults();
	var _state = global.tradeup_state;
	if (!tcc_steam_initialised() || tradeup_handle_valid(_state.trade_handle) || tradeup_handle_valid(_state.inventory_handle)) return false;
	_state.ready = false;
	_state.inventory_handle = tcc_steam_inventory_get_all_items();
	if (!tradeup_handle_valid(_state.inventory_handle)) {
		_state.inventory_handle = -1; _state.phase = "idle";
		_state.message = "Inventory unavailable. Press R to refresh.";
		return false;
	}
	_state.phase = "refreshing";
	_state.inventory_started = current_time;
	return true;
}

/// The persistent inventory controller owns both handles, even after a menu closes.
function tradeup_inventory_event(_event) {
	tradeup_defaults();
	var _state = global.tradeup_state;
	if (tradeup_result_matches(_event,_state.trade_handle)) {
		var _success = ds_map_exists(_event,"success") && _event[? "success"];
		tcc_steam_inventory_result_destroy(_state.trade_handle);
		_state.trade_handle = -1;
		_state.ready = false;
		_state.outcome = _success ? "Trade successful!" : "Trade failed. Your inventory will be refreshed.";
		_state.message = _state.outcome;
		_state.phase = "idle";
		tradeup_request_inventory();
		return true;
	}
	if (!tradeup_result_matches(_event,_state.inventory_handle)) return false;
	var _success = ds_map_exists(_event,"success") && _event[? "success"];
	var _snapshot = _success ? tradeup_inventory_snapshot(tcc_steam_inventory_result_get_items(_state.inventory_handle)) : {ok:false};
	tcc_steam_inventory_result_destroy(_state.inventory_handle);
	_state.inventory_handle = -1;
	_state.phase = "idle";
	_state.ready = _snapshot.ok;
	if (_snapshot.ok) {
		global.itemdef = _snapshot.counts;
		global.item_ids = _snapshot.stacks;
		_state.revision += 1;
		_state.message = _state.outcome;
		_state.outcome = "";
	} else {
		_state.message = (_state.outcome == "" ? "" : _state.outcome + " ") + "Inventory unavailable. Press R to refresh.";
	}
	return true;
}

function tradeup_inventory_tick() {
	tradeup_defaults();
	var _state = global.tradeup_state;
	if (tradeup_handle_valid(_state.inventory_handle) && current_time - _state.inventory_started > 30000) {
		tcc_steam_inventory_result_destroy(_state.inventory_handle);
		_state.inventory_handle = -1; _state.phase = "idle"; _state.ready = false;
		_state.message = "Inventory refresh timed out. Press R to retry.";
	}
	// An exchange cannot be safely cancelled locally: keep it locked until Steam replies.
	if (tradeup_handle_valid(_state.trade_handle) && current_time - _state.trade_started > 30000)
		_state.message = "Waiting for Steam. You can close this menu safely.";
}

function tradeup_inventory_cleanup() {
	tradeup_defaults();
	var _state = global.tradeup_state;
	if (tradeup_handle_valid(_state.trade_handle)) tcc_steam_inventory_result_destroy(_state.trade_handle);
	if (tradeup_handle_valid(_state.inventory_handle)) tcc_steam_inventory_result_destroy(_state.inventory_handle);
	_state.trade_handle = -1; _state.inventory_handle = -1; _state.phase = "idle"; _state.ready = false;
}

/// Returns the item_def for a given skin_id and tier (1=Common, 5=Legendary)
function scr_get_item_def_for_tier(skin_id, tier) {
	return skin_id * 5 + 95 + (5 - tier);
}

/// Returns true if the player can trade up the given skin from current_tier
function scr_can_trade_up(skin_id, current_tier) {
	tradeup_defaults();
	if (!global.tradeup_state.ready || global.tradeup_state.phase != "idle"
		|| !tradeup_integer(skin_id,1,50) || !tradeup_integer(current_tier,1,4)) return false;
	var source_def = scr_get_item_def_for_tier(skin_id, current_tier);
	if (!variable_global_exists("item_ids") || !is_array(global.item_ids) || array_length(global.item_ids) <= source_def) return false;
	return !is_undefined(tradeup_plan(skin_id,current_tier,global.item_ids[source_def]));
}

/// Executes a trade-up: consumes 5 items of current_tier, creates 1 of current_tier+1
/// Returns the async handle from steam_inventory_exchange_items
function scr_execute_trade_up(skin_id, current_tier) {
	if (!tcc_steam_initialised() || !scr_can_trade_up(skin_id,current_tier)) return undefined;
	var source_def = scr_get_item_def_for_tier(skin_id, current_tier);
	var _plan = tradeup_plan(skin_id,current_tier,global.item_ids[source_def]);
	var _handle = tcc_steam_inventory_exchange_items(_plan.create,_plan.destroy);
	if (!tradeup_handle_valid(_handle)) { global.tradeup_state.message = "Steam could not start the trade."; return undefined; }
	var _state = global.tradeup_state;
	_state.trade_handle = _handle; _state.phase = "exchanging"; _state.ready = false;
	_state.trade_started = current_time; _state.message = "Trading..."; _state.outcome = "";
	return _handle;
}

/// Returns the display name for a mastery tier (1-5)
function scr_get_tier_name(tier) {
	switch (tier) {
		case 1: return "Common";
		case 2: return "Uncommon";
		case 3: return "Rare";
		case 4: return "Epic";
		case 5: return "Legendary";
		default: return "Unknown";
	}
}

/// Returns the display color for a mastery tier
function scr_get_tier_color(tier) {
	switch (tier) {
		case 1: return make_color_rgb(180, 180, 180); // Gray
		case 2: return make_color_rgb(30, 200, 30);   // Green
		case 3: return make_color_rgb(50, 120, 255);   // Blue
		case 4: return make_color_rgb(180, 50, 255);   // Purple
		case 5: return make_color_rgb(255, 200, 50);   // Gold
		default: return c_white;
	}
}

/// Returns an array of skin name strings indexed by skin_id (1-50)
function scr_get_skin_names() {
	var names = array_create(51, "");
	names[1] = "Normal"; names[2] = "Kaizo"; names[3] = "Mad";
	names[4] = "Blind"; names[5] = "Sad"; names[6] = "Block";
	names[7] = "HD"; names[8] = "Rewarded"; names[9] = "Angry";
	names[10] = "Cool"; names[11] = "Dark Knight"; names[12] = "Rich";
	names[13] = "Gold"; names[14] = "Frozen"; names[15] = "Kinda Dead";
	names[16] = "Corona"; names[17] = "Canadian"; names[18] = "Hazardous";
	names[19] = "Baby"; names[20] = "Hexagon"; names[21] = "Tuxedo";
	names[22] = "Animated"; names[23] = "Underwater"; names[24] = "forsenE";
	names[25] = "Red Ball"; names[26] = "Bomber"; names[27] = "Hitbox";
	names[28] = "Metallic"; names[29] = "Monocle"; names[30] = "Japanese";
	names[31] = "Googly"; names[32] = "Upside-Down"; names[33] = "Spiral";
	names[34] = "Heart"; names[35] = "Clock"; names[36] = "Invisible";
	names[37] = "Spike"; names[38] = "Arrow"; names[39] = "Split";
	names[40] = "Pirate"; names[41] = "Sci-fi"; names[42] = "Gordon";
	names[43] = "Fancy"; names[44] = "Steam"; names[45] = "Breakable";
	names[46] = "Smiley"; names[47] = "Maid"; names[48] = "Burning";
	names[49] = "Toilet"; names[50] = "Kratos";
	return names;
}

/// Returns an array of skin sprite assets indexed by skin_id (1-50)
function scr_get_skin_sprites() {
	var sprites = array_create(51, s_lockedskinicon);
	sprites[1] = s_normalskinbutton; sprites[2] = s_kaizoskinbutton;
	sprites[3] = s_madskinbutton; sprites[4] = s_blindskinbutton;
	sprites[5] = s_sadskinbutton; sprites[6] = s_blockskinbutton;
	sprites[7] = s_hdskinbutton; sprites[8] = s_rewardedskinbutton;
	sprites[9] = s_angryskinbutton; sprites[10] = s_coolskinbutton;
	sprites[11] = s_darkknightskinbutton; sprites[12] = s_richskinbutton;
	sprites[13] = s_goldplayerskinbutton; sprites[14] = s_frozenskinbutton;
	sprites[15] = s_kindadeadskinbutton; sprites[16] = s_coronaskinbutton;
	sprites[17] = s_canadianskinbutton; sprites[18] = s_hazardousskinbutton;
	sprites[19] = s_babyskinbutton; sprites[20] = s_hexagonskinbutton;
	sprites[21] = s_tuxedoskinbutton; sprites[22] = s_normalskinbutton;
	sprites[23] = s_waterskinbutton; sprites[24] = s_forsenEskinbutton;
	sprites[25] = s_redballskinbutton; sprites[26] = s_bomberskinbutton;
	sprites[27] = s_hitboxskinbutton; sprites[28] = s_metallicskinbutton;
	sprites[29] = s_monocleskinbutton; sprites[30] = s_japaneseskinbutton;
	sprites[31] = s_googlyskinbutton; sprites[32] = s_upsidedownskinbutton;
	sprites[33] = s_spiralskinbutton; sprites[34] = s_heartskinbutton;
	sprites[35] = s_clockskinbutton; sprites[36] = s_invisibleskinbutton;
	sprites[37] = s_spikeskinbutton; sprites[38] = s_arrowskinbutton;
	sprites[39] = s_splitskinbutton; sprites[40] = s_pirateskinbutton;
	sprites[41] = s_scifiskinbutton; sprites[42] = s_gordonskinbutton;
	sprites[43] = s_fancyskinbutton; sprites[44] = s_steamskinbutton;
	sprites[45] = s_breakableskinbutton; sprites[46] = s_smileyskinbutton;
	sprites[47] = s_maidskinbutton; sprites[48] = s_burningskinbutton;
	sprites[49] = s_toiletskinbutton; sprites[50] = s_kratosskinbutton;
	return sprites;
}

/// Builds the list of eligible trade-up entries
/// Returns array of structs { skin_id, tier, item_def, quantity, name, sprite }
function scr_build_tradeup_list() {
	var list = [];
	tradeup_defaults();
	if (!global.tradeup_state.ready || !variable_global_exists("itemdef") || !is_array(global.itemdef)) return list;
	var names = scr_get_skin_names();
	var sprites = scr_get_skin_sprites();

	for (var skin_id = 1; skin_id <= 50; skin_id++) {
		for (var tier = 1; tier <= 4; tier++) { // Tiers 1-4 can trade up (not Legendary)
			var def = scr_get_item_def_for_tier(skin_id, tier);
			var qty = global.itemdef[def];
			if qty >= 5 && scr_can_trade_up(skin_id,tier) {
				array_push(list, {
					skin_id: skin_id,
					tier: tier,
					item_def: def,
					quantity: qty,
					name: names[skin_id],
					sprite: sprites[skin_id]
				});
			}
		}
	}

	return list;
}

/// Pure native Check fixtures: no Steam call, exchange, inventory award or save.
function scr_tradeup_selfcheck() {
    var _large_id = int64("9007199254741003");
    var _items = [
        {item_id:_large_id,item_def:104,quantity:2,flags:0},
        {item_id:int64(92),item_def:104,quantity:4,flags:0},
        {item_id:int64(93),item_def:104,quantity:100,flags:256},
        {item_id:int64(94),item_def:104,quantity:100,flags:512},
        {item_id:int64(95),item_def:109,quantity:1,flags:0}
    ];
    var _snapshot = tradeup_inventory_snapshot(_items);
    scr_port_assert(_snapshot.ok && _snapshot.counts[104] == 6 && _snapshot.counts[109] == 1,
        "inventory sums independent stacks and omits removed/consumed entries");
    var _plan = tradeup_plan(1,1,_snapshot.stacks[104]);
    scr_port_assert(!is_undefined(_plan) && array_length(_plan.destroy) == 2
        && _plan.destroy[0].quantity == 2 && _plan.destroy[1].quantity == 3
        && _plan.create[0].item_def == 103 && _plan.create[0].quantity == 1,
        "trade consumes exactly five stacked Common copies for one Uncommon copy");
    scr_port_assert(_plan.destroy[0].item_id == _large_id && string(_plan.destroy[0].item_id) == "9007199254741003",
        "inventory instance id preserves int64 precision");
    scr_port_assert(_snapshot.stacks[104][1].quantity == 4 && _items[1].quantity == 4,
        "preparing a trade never mutates inventory or grants its output");
    var _short = [{item_id:int64(1),quantity:4}];
    scr_port_assert(is_undefined(tradeup_plan(1,1,_short)),"four copies cannot trade");
    scr_port_assert(is_undefined(tradeup_plan(0,1,_short)) && is_undefined(tradeup_plan(51,1,_short))
        && is_undefined(tradeup_plan(1,0,_short)) && is_undefined(tradeup_plan(1,5,_short)),
        "trade recipe excludes invalid skins and Legendary source tier");
    scr_port_assert(is_undefined(tradeup_plan(1,1,[{item_id:int64(1),quantity:-5}])),"negative stack cannot trade");
    scr_port_assert(is_undefined(tradeup_plan(1,1,[{item_id:int64(1),quantity:3},{item_id:int64(1),quantity:3}])),
        "one inventory instance cannot be spent twice");
    scr_port_assert(!tradeup_inventory_snapshot([_items[0],_items[0]]).ok,
        "duplicate inventory ids reject the entire ambiguous snapshot");
    for (var _skin = 1; _skin <= 50; ++_skin) {
        for (var _tier = 1; _tier <= 4; ++_tier) {
            var _recipe = tradeup_plan(_skin,_tier,[{item_id:int64(1),quantity:12}]);
            scr_port_assert(_recipe.destroy[0].quantity == 5 && _recipe.create[0].quantity == 1
                && _recipe.create[0].item_def == _recipe.source_def-1,"all supported recipes retain the five-to-one economy");
        }
    }
    var _event = ds_map_create();
    _event[? "event_type"] = "inventory_result_ready"; _event[? "handle"] = 5;
    scr_port_assert(tradeup_result_matches(_event,5) && !tradeup_result_matches(_event,6)
        && !tradeup_result_matches(_event,-1),"only matching live inventory result is accepted");
    _event[? "event_type"] = "inventory_full_update";
    scr_port_assert(!tradeup_result_matches(_event,5),"unrelated inventory event cannot complete a trade");
    ds_map_destroy(_event);
    scr_port_assert(!tradeup_handle_valid(undefined) && !tradeup_handle_valid(-1),"failed exchange handle is never treated as pending");
    show_debug_message("TCC_TRADEUP_SELF_CHECK_PASS");
}
