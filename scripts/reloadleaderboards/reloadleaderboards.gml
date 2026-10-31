function reloadleaderboards(){
switch(global.leaderboardselect) {
case(-4): lbname = "Cog Distance" break;
case(-3): lbname = "Endless Run" break;
case(-2): lbname = "Old School Endless Run" break;
case(-1): lbname = "Seasonal Endless Run" break;
case(0): lbname = "World 1 Time" break;
case(1): lbname = "World 2 Time" break;
case(2): lbname = "World 3 Time" break;
case(3): lbname = "World 4 Time" break;
case(4): lbname = "World 5 Time" break;
case(5): lbname = "Tutorial Challenge Time" break;
case(6): lbname = "Ladder Challenge Time" break;
case(7): lbname = "Invisible Challenge Time" break;
case(8): lbname = "Big Room Challenge Time" break;
case(9): lbname = "Slippery Challenge Time" break;
case(10): lbname = "DJ Challenge Time" break;
case(11): lbname = "Blind Challenge Time" break;
case(12): lbname = "Troop Challenge Time" break;
case(13): lbname = "Speed Challenge Time" break;
case(14): lbname = "Water Challenge Time" break;
case(15): lbname = "Moving Challenge Time" break;
case(16): lbname = "Breakable Challenge Time" break;
case(17): lbname = "Spike Challenge Time" break;
case(18): lbname = "Community Challenge Time" break;
case(19): lbname = "Corrupted Spike Challenge Time" break;
case(20): lbname = "Kaizo Challenge Time" break;
case(21): lbname = "World 6 Challenge Time" break;
case(22): lbname = "World 7 Challenge Time" break;
}
lb_req += 1
alarm[0] = -1
for(var i = 0; i < 100; i++;)
        {
steam_name[i] = ""
steam_score[i] = 0
steam_rank[i] = 0
steam_userid[i] = noone
		}

if (ds_exists(avatar_sprites, ds_type_map)) {
	var key = ds_map_find_first(avatar_sprites);
	while (key != undefined) {
		var spr = ds_map_find_value(avatar_sprites, key);
		if (sprite_exists(spr)) { sprite_delete(spr) }
		key = ds_map_find_next(avatar_sprites, key);
	}
	ds_map_clear(avatar_sprites);
}

// Only the newest request may fill the rows (the board changes quickly with the arrow keys)
var _rows_callback = method({inst: id, token: lb_req}, function(_rows) {
	if (inst.lb_req != token || is_undefined(_rows)) return;
	with (inst) {
		leaderboard_apply_rows(_rows);
		leaderboard_refresh_users(0);
	}
});
if global.friendleaderboardsettings = 0 {
tcc_steam_download_scores(lbname, 1, 100, _rows_callback, id);
} else {
tcc_steam_download_friends_scores(lbname, _rows_callback, id);
}
}

// Runs as the leaderboard instance: copies the rows of a download into the row arrays
function leaderboard_apply_rows(_rows) {
	var _count = min(array_length(_rows), 100);
	for (var _i = 0; _i < _count; _i++) {
		steam_name[_i] = _rows[_i].name;
		steam_score[_i] = _rows[_i].score;
		steam_rank[_i] = _rows[_i].rank;
		steam_userid[_i] = _rows[_i].steam_id;
	}
	avatar_round = 0;
}

// Runs as the leaderboard instance, first from the rows callback and then from the alarm slot given in _alarm.
// Builds the avatar sprite of every listed player and fills names Steam did not know yet. avatar_sprites holds
// the sprite, -2 while the avatar is still on its way and -1 once there is none.
// Asks again after TCC_AVATAR_RETRY_MS, at most TCC_AVATAR_RETRY_MAX times, as long as something is missing.
function leaderboard_refresh_users(_alarm) {
	var _retry = (avatar_round < TCC_AVATAR_RETRY_MAX);
	var _more = false;
	for (var _i = 0; _i < 100; _i++) {
		var _user_id = steam_userid[_i];
		if (!tcc_steam_id_valid(_user_id)) continue;

		if (steam_name[_i] == "") {
			var _name = tcc_steam_get_user_persona_name_sync(_user_id);
			if (_name != "") {
				steam_name[_i] = _name;
			} else if (_retry) {
				_more = true;
			} else {
				steam_name[_i] = "Unknown";
			}
		}

		var _user_key = string(_user_id);
		if (ds_map_exists(avatar_sprites, _user_key) && ds_map_find_value(avatar_sprites, _user_key) != -2) continue;
		var _img = tcc_steam_get_user_avatar(_user_id, avatar_request_size);
		if (_img > 0) {
			ds_map_set(avatar_sprites, _user_key, tcc_steam_image_to_sprite(_img));
		} else if (_img == TCC_AVATAR_PENDING && _retry) {
			ds_map_set(avatar_sprites, _user_key, -2);
			_more = true;
		} else {
			ds_map_set(avatar_sprites, _user_key, -1);
		}
	}
	avatar_round += 1;
	if (_more) {
		alarm[_alarm] = max(1, round(TCC_AVATAR_RETRY_MS * TCC_SIM_HZ / 1000));
		timing_register_instance(id);	// the alarm can be armed from the Steam callback, outside this instance's own events
	}
}
