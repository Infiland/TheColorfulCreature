/// @description Click to start
if steam_get_app_id() = 1749610 {
if !instance_exists(o_demoask) {instance_create(x,y,o_demoask)}
exit;
}

if os_type != os_android {
if room = r_endlessrunmenu {
global.leaderboardselect = -2	
}

room_goto(r_onlineleaderboard)

window_set_cursor(cr_default)
} else {
GooglePlayServices_Leaderboard_ShowAll()	
}
