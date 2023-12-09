function reloadleaderboardsmini(){
for(var i = 0; i < 100; i++;)
        {
steam_name[i] = ""
steam_score[i] = 0
steam_rank[i] = 0
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