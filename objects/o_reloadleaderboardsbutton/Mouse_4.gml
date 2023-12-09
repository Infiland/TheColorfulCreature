if os_type != os_android {
if instance_exists(o_onlineleaderboards) {
with o_onlineleaderboards {
reloadleaderboards()
}}
if instance_exists(o_onlineleaderboardsmini) {
with o_onlineleaderboardsmini {
	reloadleaderboardsmini()
}}} else {
GooglePlayServices_Leaderboard_ShowAll()	
}
