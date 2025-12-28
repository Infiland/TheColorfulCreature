dragy = 0

rank = 0
xp = 0

yscroll = 0
yscrollreal = 0

// Special rainbow colors
red = 255
green = 255
blue = 255
if rank = 2 {
	red = 255
	green = 0
	blue = 255
}
change = 0
color = make_color_rgb(red, green, blue)

// Hats bugfix
scr_savehats()

// Layout
stats_margin_x = 32
stats_header_y = 72
stats_header_h = 90
stats_view_top = stats_header_y + stats_header_h + 16
stats_view_bottom = room_height - 24
stats_card_gap = 18
stats_card_header_h = 26
stats_card_padding = 12
stats_row_h = 22
stats_bar_w = 160
stats_bar_h = 6

stats_scroll_max = 0
stats_content_height = 0
stats_ach_tick = 0
stats_ach_update_rate = 60

// Data sets
stats_normal_skin_ids = [1,2,3,4,5,6,7,8,9,10,12,14,15,16,17,19,20,21,23,24,26,27,28,29,30,31,32,33,34,36,37,38,39,40,42,43,44,45,46,47,48,49,50]
stats_leg_skin_ids = [11,13,18,22,25,35,41]
stats_challenge_skin_ids = [2,4,10,11,14,16,17,19,21,23,28,31,40,37,41,43,45]
stats_challenge_deaths = [
	"kaizochallengedeaths",
	"blindchallengedeaths",
	"bigroomchallengedeaths",
	"troopchallengedeaths",
	"slipperychallengedeaths",
	"world6challengedeaths",
	"ladderchallengedeaths",
	"tutorialchallengedeaths",
	"spikechallengedeaths",
	"waterchallengedeaths",
	"movingchallengedeaths",
	"communitychallengedeaths",
	"djumpchallengedeaths",
	"cspikechallengedeaths",
	"world7challengedeaths",
	"speedchallengedeaths",
	"invisiblechallengedeaths",
	"breakablechallengedeaths"
]
stats_rank_thresholds = [2500000,1500000,1000000,750000,550000,400000,300000,225000,170000,125000,95000,70000,50000,35000,27500,20000,15000,11500,9000,6000,4000,2500,1400,700,400,200,100]

// Labels
stats_label_rank = loc(59) + ": "
stats_label_full = loc(128) + ": "
stats_rank_names = [
	loc(301),
	loc(301) + " +",
	loc(301) + " ++",
	loc(302),
	loc(302) + " +",
	loc(302) + " ++",
	loc(303),
	loc(303) + " +",
	loc(303) + " ++",
	loc(304),
	loc(304) + " +",
	loc(304) + " ++",
	loc(305),
	loc(305) + " +",
	loc(305) + " ++",
	loc(306),
	loc(306) + " +",
	loc(306) + " ++",
	loc(307),
	loc(307) + " +",
	loc(307) + " ++",
	loc(308),
	loc(308) + " +",
	loc(308) + " ++",
	loc(309),
	loc(309) + " +",
	loc(309) + " ++"
]

stats_reqnormalskins = 43
stats_reqlegskins = 7
stats_reqchallenge = 18
stats_reqperfectchallenge = 18
stats_reqHM = 7
stats_reqW = 7
stats_reqach = 148

stats_count_by_ids = function(id_list) {
	var count = 0
	var i = 0
	for (i = 0; i < array_length(id_list); i++) {
		if global.skin[id_list[i]] = 1 { count += 1 }
	}
	return count
}

stats_count_global_array = function(arr, max_index) {
	if max_index < 0 { return 0 }
	var count = 0
	var i = 0
	for (i = 0; i <= max_index; i++) {
		if arr[i] = 1 { count += 1 }
	}
	return count
}

stats_safe_div = function(n, d) {
	if d <= 0 { return 0 }
	return n / d
}

stats_format_time = function(seconds) {
	var total = max(0, floor(seconds))
	var hours = floor(total / 3600)
	var minutes = floor((total mod 3600) / 60)
	if hours > 0 {
		return string(hours) + "h " + string(minutes) + "m"
	}
	return string(minutes) + "m"
}

stats_format_number = function(value, decimals) {
	return string_format(value, 0, decimals)
}

stats_entry = function(label_id, key, format, max, max_key) {
	var entry = { label: loc(label_id) + ": ", key: key, format: format }
	if !is_undefined(max) { entry.max = max }
	if !is_undefined(max_key) { entry.max_key = max_key }
	return entry
}

stats_entry_calc = function(label_id, getter, format, max, max_key) {
	var entry = { label: loc(label_id) + ": ", getter: getter, format: format }
	if !is_undefined(max) { entry.max = max }
	if !is_undefined(max_key) { entry.max_key = max_key }
	return entry
}

stats_struct_has = function(entry, field) {
	return variable_struct_exists(entry, field)
}

stats_struct_get = function(entry, field, fallback) {
	if variable_struct_exists(entry, field) { return variable_struct_get(entry, field) }
	return fallback
}

stats_entry_value = function(entry) {
	if stats_struct_has(entry, "getter") { return stats_struct_get(entry, "getter", undefined)() }
	if stats_struct_has(entry, "key") { return variable_global_get(stats_struct_get(entry, "key", "")) }
	if stats_struct_has(entry, "value") { return stats_struct_get(entry, "value", 0) }
	return 0
}

stats_entry_max = function(entry) {
	if stats_struct_has(entry, "max_getter") { return stats_struct_get(entry, "max_getter", undefined)() }
	if stats_struct_has(entry, "max_key") { return variable_global_get(stats_struct_get(entry, "max_key", "")) }
	if stats_struct_has(entry, "max") { return stats_struct_get(entry, "max", -1) }
	return -1
}

stats_format_value = function(entry, value, max) {
	switch(entry.format) {
		case "time": return stats_format_time(value)
		case "float1": return stats_format_number(value, 1)
		case "minutes": return stats_format_number(value, 1) + "m"
		case "percent": return stats_format_number(value, 0) + "%"
		case "ratio":
			var pct = stats_safe_div(value, max) * 100
			return stats_format_number(value, 0) + "/" + stats_format_number(max, 0) + " (" + stats_format_number(pct, 0) + "%)"
	}
	return stats_format_number(value, 0)
}

stats_rank_from_score = function(score) {
	var result = 27
	var i = 0
	for (i = 0; i < array_length(stats_rank_thresholds); i++) {
		if score < stats_rank_thresholds[i] {
			result = array_length(stats_rank_thresholds) - 1 - i
		}
	}
	return result
}

stats_rank_name = function(rank_value) {
	if rank_value >= 0 && rank_value < array_length(stats_rank_names) {
		return stats_rank_names[rank_value]
	}
	return "Reddie"
}

stats_tier = function(value) {
	if value <= 0 { return 0 }
	var tier = floor(ln(value + 1) / ln(10)) + 1
	return clamp(tier, 0, 5)
}

stats_category_has_progress = function(category) {
	var items = category.items
	var i = 0
	for (i = 0; i < array_length(items); i++) {
		var entry = items[i]
		if stats_struct_has(entry, "max") || stats_struct_has(entry, "max_key") || stats_struct_has(entry, "max_getter") {
			return true
		}
	}
	return false
}

stats_category_height = function(category) {
	var rows = array_length(category.items)
	var h = stats_card_header_h + stats_card_padding + (rows * stats_row_h) + stats_card_padding
	if stats_category_has_progress(category) { h += stats_bar_h + 6 }
	return h
}

stats_compute_scroll = function() {
	var total = 0
	var i = 0
	for (i = 0; i < array_length(stats_categories); i++) {
		total += stats_category_height(stats_categories[i])
		if i < array_length(stats_categories) - 1 { total += stats_card_gap }
	}
	stats_content_height = total
	var view_height = stats_view_bottom - stats_view_top
	stats_scroll_max = max(0, stats_content_height - view_height)
}

stats_refresh_achievements = function() {
	allach = 0
	scr_achievementstats()
	stats_allach = allach
	stats_ach_pct = clamp(stats_safe_div(stats_allach, stats_reqach) * 100, 0, 100)
}

stats_refresh = function() {
	stats_totalpickups = global.totalcoins + global.totalnormalpickups + global.totalgravitypickups + global.totalspeedpickups + global.totalusepickups + global.totalkeypickups + global.totaltorchpickups + global.totalammopickups + global.totalgunpickups + global.total1ups + global.totaloxygenpickups + global.totaldjumppickups
	global.totalpickups = stats_totalpickups

	stats_normalskins = stats_count_by_ids(stats_normal_skin_ids)
	stats_legskins = stats_count_by_ids(stats_leg_skin_ids)
	stats_normalskins_pct = clamp(stats_safe_div(stats_normalskins, stats_reqnormalskins) * 100, 0, 100)
	stats_legskins_pct = clamp(stats_safe_div(stats_legskins, stats_reqlegskins) * 100, 0, 100)

	stats_allhats = stats_count_global_array(global.hat, global.totalhatsAM)
	stats_hats_pct = clamp(stats_safe_div(stats_allhats, global.totalhatsAM) * 100, 0, 100)

	stats_allitems = stats_count_global_array(global.item, global.totalitemsAM)
	stats_items_pct = clamp(stats_safe_div(stats_allitems, global.totalitemsAM) * 100, 0, 100)

	var challengebugfix = 0
	if global.hat[1] != -1 { challengebugfix = 1 }
	stats_challenge_progress = stats_count_by_ids(stats_challenge_skin_ids) + challengebugfix
	stats_challenge_pct = clamp(stats_safe_div(stats_challenge_progress, stats_reqchallenge) * 100, 0, 100)

	stats_perfectchallenge = 0
	var c = 0
	for (c = 0; c < array_length(stats_challenge_deaths); c++) {
		if variable_global_get(stats_challenge_deaths[c]) = 0 { stats_perfectchallenge += 1 }
	}
	stats_perfectchallenge_pct = clamp(stats_safe_div(stats_perfectchallenge, stats_reqperfectchallenge) * 100, 0, 100)

	stats_hm_progress = max(global.hardmodeunlock - 1, 0)
	stats_hm_pct = clamp(stats_safe_div(stats_hm_progress, stats_reqHM) * 100, 0, 100)

	stats_world_progress = global.world1 + global.world2 + global.world3 + global.world4 + global.world5 + global.skin[17] + global.skin[41]
	stats_world_pct = clamp(stats_safe_div(stats_world_progress, stats_reqW) * 100, 0, 100)

	stats_game_progress = (stats_world_pct + stats_hm_pct + stats_ach_pct + stats_legskins_pct + stats_challenge_pct + stats_perfectchallenge_pct + stats_hats_pct + stats_normalskins_pct + stats_items_pct) / 9
	stats_game_progress = clamp(stats_game_progress, 0, 100)

	stats_avg_deaths = stats_safe_div(global.totaldeaths, global.totallevelcompleted)
	stats_avg_time = stats_safe_div(global.totaltime / 60, global.totallevelcompleted)

	stats_everything = (global.totaldeaths / 4) + (global.endlesslevelhighscore * 100) + global.totalcoins + global.total1ups + (global.totaljumps / 5) + (global.totalskips * 5) + stats_totalpickups + global.totalportal + (global.totaltime / 10) + (global.totallevelcompleted * 3) + (global.totalgunshots / 8) + global.totaldestroyedboxes + global.totalenemykills + (global.totalrocketkills / 2) + (global.totalgoldspikedeaths * 100) + (global.totalweirdspikedeaths * 1000) + global.totalblockdeaths

	stats_rank = stats_rank_from_score(stats_everything)
	rank = stats_rank
	stats_rank_label = stats_rank_name(stats_rank)

	xp = lerp(xp, stats_everything, 0.1)
	stats_xp_fill = clamp(ln(xp + 1) / 15, 0, 1)
}

stats_category = function(title, accent, items) {
	return { title: title, accent: accent, items: items }
}

stats_draw_category = function(category, x, y, w) {
	var header_h = stats_card_header_h
	var pad = stats_card_padding
	var row_h = stats_row_h
	var bar_h = stats_bar_h

	var items = category.items
	var rows = array_length(items)
	var has_progress = stats_category_has_progress(category)

	var progress = -1
	if has_progress {
		var sum = 0
		var count = 0
		var i = 0
		for (i = 0; i < rows; i++) {
			var value = stats_entry_value(items[i])
			var max_value = stats_entry_max(items[i])
			if max_value > 0 {
				sum += clamp(value / max_value, 0, 1)
				count += 1
			}
		}
		if count > 0 { progress = sum / count } else { progress = 0 }
	}

	var card_h = header_h + pad + (rows * row_h) + pad
	if progress >= 0 { card_h += bar_h + 6 }

	draw_set_alpha(0.2)
	draw_set_color(c_black)
	draw_rectangle(x + 2, y + 2, x + w + 2, y + card_h + 2, false)

	draw_set_alpha(0.92)
	draw_rectangle_color(x, y + header_h, x + w, y + card_h, make_color_rgb(15, 16, 20), make_color_rgb(15, 16, 20), make_color_rgb(10, 11, 14), make_color_rgb(10, 11, 14), false)

	draw_set_alpha(0.95)
	draw_rectangle_color(x, y, x + w, y + header_h, category.accent, category.accent, category.accent, category.accent, false)

	draw_set_alpha(1)
	draw_set_color(c_black)
	draw_text(x + pad, y + 4, category.title)

	var row_y = y + header_h + pad
	if progress >= 0 {
		var prog_x = x + pad
		var prog_y = y + header_h + 4
		var prog_w = w - pad * 2

		draw_set_alpha(0.25)
		draw_set_color(c_black)
		draw_rectangle(prog_x, prog_y, prog_x + prog_w, prog_y + bar_h, false)

		draw_set_alpha(0.9)
		draw_set_color(category.accent)
		draw_rectangle(prog_x, prog_y, prog_x + prog_w * progress, prog_y + bar_h, false)

		draw_set_alpha(1)
		row_y += bar_h + 6
	}

	var i = 0
	for (i = 0; i < rows; i++) {
		var entry = items[i]
		var value = stats_entry_value(entry)
		var max_value = stats_entry_max(entry)
		var value_text = stats_format_value(entry, value, max_value)
		var label_x = x + pad + 14
		var label_w = string_width(entry.label)
		var label_right = label_x + label_w + 12

		draw_set_color(category.accent)
		draw_circle(x + pad + 6, row_y + 8, 3, false)

		draw_set_color(c_white)
		draw_set_halign(fa_left)
		draw_text(label_x, row_y, entry.label)

		var value_x = x + w - pad
		var value_w = string_width(value_text)
		var gfx_right = value_x - value_w - 10
		var gfx_space = gfx_right - label_right

		draw_set_halign(fa_right)
		draw_text(value_x, row_y, value_text)
		draw_set_halign(fa_left)

		if max_value > 0 {
			if gfx_space > 12 {
				var pct = clamp(value / max_value, 0, 1)
				var bar_w = min(stats_bar_w, gfx_space)
				var bar_x = gfx_right - bar_w
				var bar_y = row_y + row_h - 6

				draw_set_alpha(0.2)
				draw_set_color(c_black)
				draw_rectangle(bar_x, bar_y, bar_x + bar_w, bar_y + stats_bar_h, false)

				draw_set_alpha(0.85)
				draw_set_color(category.accent)
				draw_rectangle(bar_x, bar_y, bar_x + bar_w * pct, bar_y + stats_bar_h, false)

				draw_set_alpha(1)
			}
		} else {
			var tier = stats_tier(value)
			var tick_w = 8
			var tick_gap = 3
			var total_w = (tick_w * 5) + (tick_gap * 4)
			if gfx_space >= total_w {
				var tick_x = gfx_right - total_w
				var tick_y = row_y + row_h - 6
				var t = 0
				for (t = 0; t < 5; t++) {
					draw_set_alpha(t < tier ? 0.85 : 0.2)
					draw_set_color(category.accent)
					draw_rectangle(tick_x + t * (tick_w + tick_gap), tick_y, tick_x + t * (tick_w + tick_gap) + tick_w, tick_y + 4, false)
				}
				draw_set_alpha(1)
			}
		}

		row_y += row_h
	}

	draw_set_alpha(1)
	draw_set_halign(fa_left)
	return card_h
}

// Stats categories
stats_categories = [
	stats_category(loc(72), make_color_rgb(248, 184, 72), [
		stats_entry(73, "totalcoins", "num", 2500),
		stats_entry(74, "totaljumps", "num", 500000),
		stats_entry_calc(75, function() { return global.totaltime }, "time", 230400),
		stats_entry(76, "totalskips", "num"),
		stats_entry(83, "totalportal", "num"),
		stats_entry(85, "totallevelcompleted", "num", 2500),
		stats_entry(86, "customlevelcompleted", "num"),
		stats_entry(87, "newendlesslevelhighscore", "num"),
		stats_entry(88, "endlesslevelhighscore", "num"),
		stats_entry(683, "totalquests", "num")
	]),
	stats_category("Pickups", make_color_rgb(96, 210, 255), [
		stats_entry_calc(77, function() { return stats_totalpickups }, "num"),
		stats_entry(78, "totalnormalpickups", "num"),
		stats_entry(79, "totalgravitypickups", "num"),
		stats_entry(80, "totalspeedpickups", "num"),
		stats_entry(81, "totalusepickups", "num"),
		stats_entry(82, "totalkeypickups", "num"),
		stats_entry(84, "totaltorchpickups", "num"),
		stats_entry(90, "totalgunpickups", "num"),
		stats_entry(91, "totalammopickups", "num"),
		stats_entry(94, "total1ups", "num"),
		stats_entry(96, "totaloxygenpickups", "num"),
		stats_entry(97, "totaldjumppickups", "num")
	]),
	stats_category("Combat", make_color_rgb(255, 120, 96), [
		stats_entry(89, "totalgunshots", "num"),
		stats_entry(93, "totalenemykills", "num"),
		stats_entry(95, "totalrocketkills", "num"),
		stats_entry(92, "totaldestroyedboxes", "num"),
		stats_entry(617, "totalblocksbroken", "num")
	]),
	stats_category(loc(98), make_color_rgb(255, 96, 96), [
		stats_entry(99, "totaldeaths", "num", 10000),
		stats_entry(100, "totalblockdeaths", "num"),
		stats_entry(101, "totalrestartdeaths", "num"),
		stats_entry(102, "totalspikedeaths", "num"),
		stats_entry(103, "totalinvisiblespikedeaths", "num"),
		stats_entry(104, "totalverticalspikedeaths", "num"),
		stats_entry(105, "totalhorizontalspikedeaths", "num"),
		stats_entry(106, "totalgoldspikedeaths", "num"),
		stats_entry(107, "totalweirdspikedeaths", "num"),
		stats_entry(108, "totalvoiddeaths", "num"),
		stats_entry(109, "totalfiredeaths", "num"),
		stats_entry(110, "totallavadeaths", "num"),
		stats_entry(111, "totalbulletdeaths", "num"),
		stats_entry(112, "totalrocketdeaths", "num"),
		stats_entry(113, "totaltroopdeaths", "num"),
		stats_entry(114, "totalwaterdeaths", "num")
	]),
	stats_category(loc(115), make_color_rgb(148, 220, 120), [
		stats_entry_calc(116, function() { return stats_avg_deaths }, "float1"),
		stats_entry_calc(117, function() { return stats_avg_time }, "minutes")
	]),
	stats_category(loc(118), make_color_rgb(255, 214, 98), [
		stats_entry_calc(119, function() { return stats_normalskins }, "ratio", stats_reqnormalskins),
		stats_entry_calc(120, function() { return stats_legskins }, "ratio", stats_reqlegskins),
		stats_entry_calc(121, function() { return stats_allhats }, "ratio", undefined, "totalhatsAM"),
		stats_entry_calc(122, function() { return stats_allitems }, "ratio", undefined, "totalitemsAM"),
		stats_entry_calc(123, function() { return stats_hm_progress }, "ratio", stats_reqHM),
		stats_entry_calc(124, function() { return stats_challenge_progress }, "ratio", stats_reqchallenge),
		stats_entry_calc(125, function() { return stats_perfectchallenge }, "ratio", stats_reqperfectchallenge),
		stats_entry_calc(126, function() { return stats_world_progress }, "ratio", stats_reqW),
		stats_entry_calc(127, function() { return stats_allach }, "ratio", stats_reqach),
		stats_entry_calc(128, function() { return stats_game_progress }, "percent", 100)
	])
]

// Init stats
stats_refresh_achievements()
stats_refresh()
stats_compute_scroll()

if stats_normalskins_pct = 100 {
	if !steam_get_achievement("SKIN_COMPLETIONIST") {
		steam_set_achievement("SKIN_COMPLETIONIST")
	}
}

if stats_hats_pct = 100 {
	if !steam_get_achievement("HAT_COMPLETIONIST") {
		steam_set_achievement("HAT_COMPLETIONIST")
	}
}

if stats_allhats > 9 {
	if !steam_get_achievement("A_FAN_OF_HATS") {
		steam_set_achievement("A_FAN_OF_HATS")
	}
}
