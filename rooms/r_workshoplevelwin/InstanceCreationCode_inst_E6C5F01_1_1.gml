audio_stop_all()
instance_destroy(o_pausesystem)
instance_destroy(o_timecounter)
instance_destroy(o_time)
instance_destroy(o_fadecontroller)
instance_destroy(o_deathcounter)
instance_destroy(o_musicdistortion)
instance_destroy(o_ammocounter)
global.customlevelcompleted += 1
if !steam_get_achievement("WORKSHOP_BEGINNER") { steam_set_achievement("WORKSHOP_BEGINNER") }
if !steam_get_achievement("FEATURED_LEVEL") { steam_set_achievement("FEATURED_LEVEL") }	
if global.customlevelcompleted > 49 {
if global.cheats = 0 {
global.skin044 = 1
if !steam_get_achievement("WORKSHOP_MASTER") { steam_set_achievement("WORKSHOP_MASTER") }
}}
if global.time > 3 { 
global.creditscurrency += floor(1 * global.creditsmultiplier)
}
	
	var directory = directory_set("/Custom/Workshop/Medals/" + string(global.Publish_ID) + "/")
	if !directory_exists(directory) {
	directory_create(directory)
	}
	
	scr_saveworkshopmedals()
	
	if !instance_exists(o_onlineleaderboardsmini) {
	instance_create(x,y,o_onlineleaderboardsmini)	
	}


scr_saveskins()
audio_play_sound(m_goodending,0,1)