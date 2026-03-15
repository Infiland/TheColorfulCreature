function reloadleaderboardsmini(){
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
if global.workshop = 1 {
score_get = steam_download_scores_around_user("CL_" + lbname, -4, 5);
} else {
if instance_number(o_onlineleaderboardsmini) = 1 {
score_get = steam_download_scores_around_user(lbname, -9,10);
} else {
	score_get = steam_download_scores_around_user(lbname, -4,5);
}

}}
