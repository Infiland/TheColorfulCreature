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
platform_submit_score("World 1 Time", global.world1time * 1000);
}
if global.world1time < 120 {
if !achievement_earned("WORLD_1_QUICK") { achievement_award("WORLD_1_QUICK") }
}
