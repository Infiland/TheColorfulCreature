music2bugfix()

if global.dailylevel = 1 { exit }
if global.levelselect = 1 { exit }
if global.cheats = 1 { exit }
if global.endless = 1 { exit }

if global.world1time = 0 {
instance_create(x,y,o_showworldtimeHUD)	
}

global.world1time = global.time
if global.world1time > 60 {
steam_upload_score("World 1 Time", global.world1time * 1000);
}
if global.world1time < 120 {
if !steam_get_achievement("WORLD_1_QUICK") { steam_set_achievement("WORLD_1_QUICK") }
}