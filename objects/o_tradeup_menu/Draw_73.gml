// Overlay background
draw_set_alpha(0.5)
draw_rectangle_color(0,0,2000,2000,c_black,c_black,c_black,c_black,false)
draw_set_alpha(1)

draw_set_color(c_white)

var entry_count = array_length(entries)

// Title
draw_set_font(global.deathfont)
draw_set_halign(fa_center)
draw_set_valign(fa_top)
draw_text_color(room_width/2, 340, loc("TRADE_UP"), c_white, c_white, c_white, c_white, 1)

if entry_count = 0 {
	draw_set_font(fnt_secret1)
	var _empty = global.tradeup_state.ready ? "No eligible skins to trade up.\nYou need 5 items of the same skin and tier." : "Loading Steam inventory...";
	if (global.tradeup_state.phase == "idle" && !global.tradeup_state.ready) _empty = "Steam inventory is unavailable.";
	draw_text_color(room_width/2, 500, _empty, c_gray, c_gray, c_gray, c_gray, 1)
	draw_text_ext(room_width/2,630,global.tradeup_state.message,-1,760);
	draw_text(room_width/2,710,"ESC to close - R to refresh");
	draw_set_font(global.deathfont)
	draw_set_halign(fa_left)
	draw_set_valign(fa_top)
	exit
}

// Draw entries as horizontal scrolling list
for (var i = 0; i < entry_count; i++) {
	var entry = entries[i]
	var draw_x = 455 + (i - dis) * 120

	// Cull off-screen entries
	if draw_x < -100 || draw_x > room_width + 100 { continue }

	// Highlight selected
	var is_selected = (i = selected)
	var alpha = is_selected ? 1.0 : 0.5
	var scale = is_selected ? 1.2 : 0.9

	// Draw skin sprite
	draw_set_alpha(alpha)
	draw_sprite_ext(entry.sprite, 0, draw_x, 500, scale, scale, 0, c_white, alpha)

	// Draw tier color indicator below
	var tier_col = scr_get_tier_color(entry.tier)
	draw_set_font(fnt_secret1)
	draw_set_halign(fa_center)
	draw_text_color(draw_x, 560, scr_get_tier_name(entry.tier), tier_col, tier_col, tier_col, tier_col, alpha)

	// Draw quantity
	draw_text_color(draw_x, 580, "x" + string(entry.quantity), c_white, c_white, c_white, c_white, alpha)
	draw_set_alpha(1)
}

// Draw trade preview for selected entry
if selected >= 0 && selected < entry_count {
	var sel = entries[selected]
	var tier_col = scr_get_tier_color(sel.tier)
	var next_tier_col = scr_get_tier_color(sel.tier + 1)
	var tier_name = scr_get_tier_name(sel.tier)
	var next_tier_name = scr_get_tier_name(sel.tier + 1)

	draw_set_font(global.deathfont)
	draw_set_halign(fa_center)

	// "5x Common [Name] -> 1x Uncommon [Name]"
	var preview_text = "5x " + tier_name + " " + sel.name + "  >  1x " + next_tier_name + " " + sel.name
	draw_text_color(room_width/2, 630, preview_text, tier_col, tier_col, next_tier_col, next_tier_col, 1)

	draw_set_font(fnt_secret1);
	var _status = global.tradeup_state.message;
	if (global.tradeup_state.phase == "refreshing") _status = "Refreshing Steam inventory...";
	if (_status == "") _status = "Press ENTER to trade";
	draw_text_ext(room_width/2,670,_status,-1,760);
	draw_text(room_width/2,735,"ESC to close - R to refresh");
}

// Navigation arrow
draw_sprite_ext(s_liquidarrow,0,355,520,1,arrowyscale,0,c_white,1)

// Reset draw state
draw_set_halign(fa_left)
draw_set_valign(fa_top)
draw_set_color(c_white)
