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

if global.friendleaderboardsettings = 0 {
score_get = steam_download_scores(lbname, 1, 100);
} else {
score_get = steam_download_friends_scores(lbname);
}
}
