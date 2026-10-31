function reloadleaderboardsmini(){
lb_req += 1
alarm[1] = -1
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

// Only the newest request may fill the rows (a room can start several of them)
var _rows_callback = method({inst: id, token: lb_req}, function(_rows) {
	if (inst.lb_req != token || is_undefined(_rows)) return;
	with (inst) {
		leaderboard_apply_rows(_rows);
		leaderboard_refresh_users(1);
	}
});
if global.workshop = 1 {
tcc_steam_download_scores_around_user("CL_" + lbname, -4, 5, _rows_callback, id);
} else {
if instance_number(o_onlineleaderboardsmini) = 1 {
tcc_steam_download_scores_around_user(lbname, -9,10, _rows_callback, id);
} else {
	tcc_steam_download_scores_around_user(lbname, -4,5, _rows_callback, id);
}

}}
