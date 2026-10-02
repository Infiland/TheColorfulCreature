if (!timing_is_tick()) exit;
if (leaderboard_id != "") {
	platform_google_score(leaderboard_id,global.time*100)
}
