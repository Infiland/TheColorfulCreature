if platform_steam() {
if instance_exists(o_onlineleaderboards) {
with o_onlineleaderboards {
reloadleaderboards()
}}
if instance_exists(o_onlineleaderboardsmini) {
with o_onlineleaderboardsmini {
	reloadleaderboardsmini()
}}} else {
platform_show_leaderboards()
}
