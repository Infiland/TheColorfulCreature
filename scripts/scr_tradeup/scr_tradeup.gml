/// Trade-up system - combine 5 skins of a lower tier into 1 skin of the next tier

/// Returns the item_def for a given skin_id and tier (1=Common, 5=Legendary)
function scr_get_item_def_for_tier(skin_id, tier) {
	return skin_id * 5 + 95 + (5 - tier);
}

/// Returns true if the player can trade up the given skin from current_tier
function scr_can_trade_up(skin_id, current_tier) {
	if current_tier >= 5 { return false; } // Cannot trade up from Legendary
	var source_def = scr_get_item_def_for_tier(skin_id, current_tier);
	return (global.itemdef[source_def] >= 5);
}

/// Executes a trade-up: consumes 5 items of current_tier, creates 1 of current_tier+1
/// Returns the async handle from steam_inventory_exchange_items
function scr_execute_trade_up(skin_id, current_tier) {
	var source_def = scr_get_item_def_for_tier(skin_id, current_tier);
	var target_def = scr_get_item_def_for_tier(skin_id, current_tier + 1);

	// Validate item_ids are available
	var entries = global.item_ids[source_def];
	if !is_array(entries) { return undefined; }

	// Build destroy array - handle stacked items (one item_id may have quantity > 1)
	var destroy_arr = [];
	var remaining = 5;
	for (var i = 0; i < array_length(entries) && remaining > 0; i++) {
		var entry = entries[i];
		var consume = min(remaining, entry.quantity);
		array_push(destroy_arr, { item_id: entry.item_id, quantity: consume });
		remaining -= consume;
	}

	// Not enough items across all stacks
	if remaining > 0 { return undefined; }

	// Build create array with 1 item of next tier
	var create_arr = [{ item_def: target_def, quantity: 1 }];

	return steam_inventory_exchange_items(create_arr, destroy_arr);
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
	var names = scr_get_skin_names();
	var sprites = scr_get_skin_sprites();

	for (var skin_id = 1; skin_id <= global.totalskinsAM; skin_id++) {
		for (var tier = 1; tier <= 4; tier++) { // Tiers 1-4 can trade up (not Legendary)
			var def = scr_get_item_def_for_tier(skin_id, tier);
			var qty = global.itemdef[def];
			if qty >= 5 {
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
