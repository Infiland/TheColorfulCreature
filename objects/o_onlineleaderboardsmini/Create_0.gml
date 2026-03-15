if os_type = os_android || os_type = os_gxgames { instance_destroy() }
if global.hardmode = 1 { instance_destroy() 
exit;	
}
diff = 0
numerical = 0
avatar_draw_size = 16
avatar_padding = 4
avatar_request_size = steam_user_avatar_size_small
steam_userid = array_create(100, noone)
avatar_sprites = ds_map_create()

steam_image_create_sprite = function(l_img)
{
	var l_dims = steam_image_get_size(l_img);
	if (l_dims == undefined) 
		return -1;
	
	var buff_size = l_dims[0] * l_dims[1] * 4
	var l_cols = buffer_create(buff_size, buffer_fixed, 1);
	var l_sprite, l_ok;
	
	l_ok = steam_image_get_rgba(l_img, l_cols, buff_size);

	if (l_ok) 
	{
		var l_surf = surface_create(l_dims[0], l_dims[1]);
		buffer_set_surface(l_cols, l_surf, 0);
		l_sprite = sprite_create_from_surface(l_surf, 0, 0, l_dims[0], l_dims[1], false, false, 0, 0);
		surface_free(l_surf);
	} 
	else 
		l_sprite = -1;
		
	buffer_delete(l_cols);
	return l_sprite;
}

if global.workshop = 1 {
lbname = string(global.Publish_ID)
} else if global.challenges = 1 {
	var _def = scr_challenge_get_def(global.currentchallenge);
	if (!is_undefined(_def) && _def.leaderboard != "") {
		lbname = _def.leaderboard;
	} else {
		instance_destroy();
		exit;
	}
} else {
switch(room) {
case(r_gameoverscreen):
if global.endlessrunmode = 1 { lbname = "Endless Run" }
if global.endlessrunmode = 2 { lbname = "Old School Endless Run" }
if global.hardmode = 1 { instance_destroy() }
numerical = 1
break;
case(r_kaizowin): lbname = "Kaizo Challenge Time" break;
case(r_blindwin): lbname = "Blind Challenge Time" break;
case(r_bigroomwin): lbname = "Big Room Challenge Time" break;
case(r_troopwin): lbname = "Troop Challenge Time" break;
case(r_slipperywin): lbname = "Slippery Challenge Time" break;
case(r_speedwin): lbname = "Speed Challenge Time" break;
case(r_world6win): lbname = "World 6 Challenge Time" break;
case(r_ladderwin): lbname = "Ladder Challenge Time" break;
case(r_tutorialwin): lbname = "Tutorial Challenge Time" break;
case(r_spikewin): lbname = "Spike Challenge Time" break;
case(r_waterwin): lbname = "Water Challenge Time" break;
case(r_movingwin): lbname = "Moving Challenge Time" break;
case(r_communitywin): lbname = "Community Challenge Time" break;
case(r_djwin): lbname = "DJ Challenge Time" break;
case(r_cswin): lbname = "Corrupted Spike Challenge Time" break;
case(r_world7win): lbname = "World 7 Challenge Time" break;
case(r_invisiblewin): lbname = "Invisible Challenge Time" break;
case(r_breakablewin): lbname = "Breakable Challenge Time" break;
case(r_endlessrunmenu): 
if diff = 0 {
lbname = "Endless Run 20L" 
} else {
lbname = "Endless Run 50L" 
} numerical = 1 break;
case(r_dailylevelwin): 
if diff = 0 {
lbname = "Daily Level Streak"
} else {
lbname = "Current Daily Level Streak"	
} numerical = 1 break;
}
}
reloadleaderboardsmini()
alarm[0] = 5
