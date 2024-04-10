audio_stop_all()



if global.world5time = 0 {
instance_create(x,y,o_showworldtimeHUD)	
}

global.world5time = global.time - (global.world1time + global.world2time + global.world3time + global.world4time)

if global.levelselect = 0 {
if global.cheats = 0 { 
	if global.world5time > 30 {
	steam_upload_score("World 5 Time", global.world5time * 1000);
	}
	}}

musicandsoundvolumefix()	
audio_play_sound(m_goodending,0,1);

instance_destroy(o_time)
instance_destroy(o_coincounter)
instance_destroy(o_ammocounter)
instance_destroy(o_timecounter)
instance_destroy(o_deathcounter)
if global.cheats = 0 {
	
if global.hardmode = 1 {
if global.hardmodelives > 120 {
if global.skin[36] = 0 {
global.skin[36] = 1	
}}}
	
if global.hardmodedifficulty >= 1 {
global.creditscurrency += floor(25 * global.creditsmultiplier)
if !steam_get_achievement("HM_MEDIUM") { //Medium
steam_set_achievement("HM_MEDIUM") }
if global.skin[5] = 0 {
global.skin[5] = 1
}
if global.hardmodeunlock = 1 { 
	global.hardmodeunlock = 2 
	scr_savehardmode()
	}
}
if global.hardmodedifficulty >= 2 {
if !steam_get_achievement("HM_DIFFICULT") { //Difficult
steam_set_achievement("HM_DIFFICULT") }
global.creditscurrency += floor(30 * global.creditsmultiplier)
if global.skin[9] = 0 {
global.skin[9] = 1
}
if global.hardmodeunlock = 2 { 
	global.hardmodeunlock = 3 
	scr_savehardmode()
	}
}

if global.hardmodedifficulty >= 3 {
if !steam_get_achievement("HM_INSANE") { //Insane
steam_set_achievement("HM_INSANE") }
global.creditscurrency += floor(40 * global.creditsmultiplier)
if global.skin[25] = 0 {
global.skin[25] = 1
}
if global.hardmodeunlock = 3 { 
	global.hardmodeunlock = 4 
	scr_savehardmode()
	}
}

if global.hardmodedifficulty >= 4 {
if !steam_get_achievement("HM_RIDICULOUS") { //Insane
steam_set_achievement("HM_RIDICULOUS") }
global.creditscurrency += floor(55 * global.creditsmultiplier)
if global.skin[26] = 0 {
global.skin[26] = 1
}
if global.hardmodeunlock = 4 { 
	global.hardmodeunlock = 5 
	scr_savehardmode()
	}
}


if global.hardmodedifficulty >= 5 {
if !steam_get_achievement("HM_IMPOSSIBLE") { //Impossible
steam_set_achievement("HM_IMPOSSIBLE") }
global.creditscurrency += floor(70 * global.creditsmultiplier)
if global.skin[7] = 0 {
global.skin[7] = 1
}
if global.hardmodeunlock = 5 { 
	global.hardmodeunlock = 6 
	scr_savehardmode()
	}
}

if global.hardmodedifficulty >= 6 {
if !steam_get_achievement("HM_YEAHGL") { //Yeah GL
steam_set_achievement("HM_YEAHGL") }
global.creditscurrency += floor(90 * global.creditsmultiplier)
if global.skin[27] = 0 {
global.skin[27] = 1
}
if global.hardmodeunlock = 6 { 
	global.hardmodeunlock = 7 
	scr_savehardmode()
	}
}

if global.hardmodedifficulty >= 7 {
if !steam_get_achievement("HM_ETERNALSUFFERING") { //Eternal Suffering
steam_set_achievement("HM_ETERNALSUFFERING") }
global.creditscurrency += floor(200 * global.creditsmultiplier)
global.hardmodeunlock = 8
}

if global.hardmodedifficulty = 0 {
if !steam_get_achievement("YOU_WIN") { steam_set_achievement("YOU_WIN") }
GooglePlayServices_Achievements_Unlock(YOUWIN)
global.hat[35] = 0
if global.skin[8] = 0 {
global.skin[8] = 1
if global.hardmodeunlock = 0 { 
	global.hardmodeunlock = 1 
	scr_savehardmode()
	}
}}
if global.skin[20] = 0 {
if global.special = 100 {
global.skin[20] = 1
}}
global.world1 = 1
global.world2 = 1
global.world3 = 1
global.world4 = 1
global.world5 = 1
scr_saveskins()


//Achievements
if global.isgrayscale = true { //Grayscale
if global.colorblindsettings = 4 {
global.grayscaleachievement = true
global.skin[33] = 1
scr_saveachievements()
scr_checkachievements()
if !steam_get_achievement("GRAYSCALE") {
steam_set_achievement("GRAYSCALE") }
}}

if global.isinvisible = true { //Invisible
if global.skinselected = 35 {
global.invisibleachievement = true
if !steam_get_achievement("INVISIBLE_SKIN") {
steam_set_achievement("INVISIBLE_SKIN") }
}}

if global.isreversed = true { //Reverse
if global.controlsmoveleft = 39 {
if global.controlsmoveright = 37 {
if global.controlsjump = "X" {
if global.controlsinteract = "Z" {
if !steam_get_achievement("THE_REVERSE_PROBLEM") {
steam_set_achievement("THE_REVERSE_PROBLEM") }
}}}}}


scr_saveskins()

if global.levelselect = 1 { exit }
if global.world5time < 360 {
if global.endless = 0 {
if !steam_get_achievement("WORLD_5_QUICK") { steam_set_achievement("WORLD_5_QUICK") }
}}
scr_saveachievements()
}