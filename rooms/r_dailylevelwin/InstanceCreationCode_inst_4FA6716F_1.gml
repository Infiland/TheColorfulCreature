if os_type = os_android || os_type = os_gxgames {
AdMob_Banner_Create(AdMob_Banner_SMART,true)
AdMob_Banner_Show()
}
audio_stop_all()
instance_destroy(o_pausesystem)
instance_destroy(o_timecounter)
instance_destroy(o_time)
instance_destroy(o_fadecontroller)
instance_destroy(o_deathcounter)
instance_destroy(o_musicdistortion)
if global.cheats = 0 {
global.dailylevelstreak += 1
var cheatcheck = global.dailylevelhighstreak - global.dailylevelstreak
steam_upload_score("Current Daily Level Streak", global.dailylevelstreak);
if global.dailylevelstreak > global.dailylevelhighstreak {
	if cheatcheck >= -1 {
	global.dailylevelhighstreak = global.dailylevelstreak
	steam_upload_score("Daily Level Streak", global.dailylevelhighstreak);
	GooglePlayServices_Leaderboard_SubmitScore("CgkI36PRjvEQEAIQMQ",global.dailylevelhighstreak,"")
	} else { global.cheats = 1
	global.dailylevelstreak = 0
	global.dailylevelhighstreak = 0
	scr_savedaily()
		}
}
if global.dailylevelstreak < 10 {
global.creditscurrency += floor((5 * global.dailylevelstreak) * global.creditsmultiplier)
} else { global.creditscurrency += floor(50  * global.creditsmultiplier) }
}
scr_saveskins()
audio_play_sound(m_goodending,0,1)

global.dailylevelyear = global.calendarcurrentyear
global.dailylevelmonth = global.calendarcurrentmonth
global.dailylevelday = global.calendarcurrentday
scr_savedaily();
