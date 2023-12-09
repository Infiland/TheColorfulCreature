music4bugfix()
audio_stop_sound(m_bosswin)

if global.dailylevel = 1 { exit }
if global.levelselect = 1 { exit }
if global.cheats = 1 { exit }
if global.endless = 1 { exit }

if global.world3time = 0 {
instance_create(x,y,o_showworldtimeHUD)	
}

global.world3time = global.time - (global.world1time + global.world2time)
if global.world3time > 30 {
steam_upload_score("World 3 Time", global.world3time * 1000);
}

if global.world3time < 240 {
if !steam_get_achievement("WORLD_3_QUICK") { steam_set_achievement("WORLD_3_QUICK") }
}