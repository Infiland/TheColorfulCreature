function scr_achievementstats(){
//Coins
if global.totalcoins >= 2500 { allach += 1 }
if global.totalcoins >= 750 { allach += 1 }
if global.totalcoins >= 250 { allach += 1 }
if global.totalcoins >= 150 { allach += 1 }
if global.totalcoins >= 100 { allach += 1 }
if global.totalcoins >= 75 { allach += 1 }
if global.totalcoins >= 50 { allach += 1 }
if global.totalcoins >= 30 { allach += 1 }
if global.totalcoins >= 15 { allach += 1 }
if global.totalcoins >= 5 { allach += 1 }
if global.totalcoins >= 1 { allach += 1 }
//Deaths
if global.totaldeaths >= 10000 { allach += 1 }
if global.totaldeaths >= 3000 { allach += 1 }
if global.totaldeaths >= 1000 { allach += 1 }
if global.totaldeaths >= 500 { allach += 1 }
if global.totaldeaths >= 300 { allach += 1 }
if global.totaldeaths >= 175 { allach += 1 }
if global.totaldeaths >= 100 { allach += 1 }
if global.totaldeaths >= 50 { allach += 1 }
if global.totaldeaths >= 25 { allach += 1 }
if global.totaldeaths >= 10 { allach += 1 }
if global.totaldeaths >= 1 { allach += 1 }
//Levels
if global.totallevelcompleted >= 2500 { allach += 1 }
if global.totallevelcompleted >= 750 { allach += 1 }
if global.totallevelcompleted >= 250 { allach += 1 }
if global.totallevelcompleted >= 150 { allach += 1 }
if global.totallevelcompleted >= 100 { allach += 1 }
if global.totallevelcompleted >= 75 { allach += 1 }
if global.totallevelcompleted >= 50 { allach += 1 }
if global.totallevelcompleted >= 30 { allach += 1 }
if global.totallevelcompleted >= 15 { allach += 1 }
if global.totallevelcompleted >= 5 { allach += 1 }
if global.totallevelcompleted >= 1 { allach += 1 }
//Time
if global.totaltime >= 230400 { allach += 1 }
if global.totaltime >= 115200 { allach += 1 }
if global.totaltime >= 86400 { allach += 1 }
if global.totaltime >= 43200 { allach += 1 }
if global.totaltime >= 28800 { allach += 1 }
if global.totaltime >= 14400 { allach += 1 }
if global.totaltime >= 7200 { allach += 1 }
if global.totaltime >= 3600 { allach += 1 }
if global.totaltime >= 1800 { allach += 1 }
if global.totaltime >= 900 { allach += 1 }
if global.totaltime >= 300 { allach += 1 }
//Jump
if global.totaljumps >= 500000 { allach += 1 }
if global.totaljumps >= 200000 { allach += 1 }
if global.totaljumps >= 60000 { allach += 1 }
if global.totaljumps >= 15000 { allach += 1 }
if global.totaljumps >= 5000 { allach += 1 }
if global.totaljumps >= 2000 { allach += 1 }
if global.totaljumps >= 1000 { allach += 1}
if global.totaljumps >= 250 { allach += 1 }
if global.totaljumps >= 100 { allach += 1 }
if global.totaljumps >= 20 { allach += 1 }
if global.totaljumps >= 1 { allach += 1 }

//Steam Achievements
if steam_get_achievement("IT_HAPPENED") { allach += 1 }
if steam_get_achievement("EASTER_EGG") { allach += 1 }
if steam_get_achievement("INVISIBLE_SKIN") { allach += 1 }
if steam_get_achievement("GRAYSCALE") { allach += 1 }
if steam_get_achievement("BOSS_KILL_1") { allach += 1 }
if steam_get_achievement("BOSS_KILL_2") { allach += 1 }
if steam_get_achievement("BOSS_KILL_3") { allach += 1 }
if steam_get_achievement("BOSS_KILL_4") { allach += 1 }
if steam_get_achievement("GOLDEN_SPIKE_DEATH") { allach += 1 }
if steam_get_achievement("WEIRD_SPIKE_DEATH") { allach += 1 }
if steam_get_achievement("FIRST_HAT") { allach += 1 }
if steam_get_achievement("FIRST_CHALLENGE") { allach += 1 }
if steam_get_achievement("PERFECT_CHALLENGE") { allach += 1 }
if steam_get_achievement("BRONZE_MEDAL") { allach += 1 }
if steam_get_achievement("SILVER_MEDAL") { allach += 1 }
if steam_get_achievement("GOLD_MEDAL") { allach += 1 }
if steam_get_achievement("DIAMOND_MEDAL") { allach += 1 }
if steam_get_achievement("DIAMOND_LOVER") { allach += 1 }
if steam_get_achievement("THE_ANTI_DEATH") { allach += 1 }
if steam_get_achievement("MAKE_LEVEL") { allach += 1 }
if steam_get_achievement("LOAD_LEVEL") { allach += 1 }
if steam_get_achievement("A_SMALL_LOAN") { allach += 1 }
if steam_get_achievement("MONEY_SAVER") { allach += 1 }
if steam_get_achievement("THE_GLITTERING_RICH") { allach += 1 }
if steam_get_achievement("BYE_BYE_LEVEL") { allach += 1 }
if steam_get_achievement("UH_OH") { allach += 1 }
if steam_get_achievement("ENDLESS_BEGINNER") { allach += 1 }
if steam_get_achievement("ENDLESS_RUNNER") { allach += 1 }
if steam_get_achievement("ENDLESS_EXPERT") { allach += 1 }
if steam_get_achievement("ENDLESS_MASTER") { allach += 1 }
if steam_get_achievement("YOUR_OWN_ENDLESS_RUN") { allach += 1 }
if steam_get_achievement("POTATO_SETTINGS") { allach += 1 }
if steam_get_achievement("BENCHMARK") { allach += 1 }
if steam_get_achievement("TROLOLOLOL") { allach += 1 }
if steam_get_achievement("HAT_MERCHANT") { allach += 1 }
if steam_get_achievement("YOU_WIN") { allach += 1 }
if steam_get_achievement("OH_NO_THERES_MORE") { allach += 1 }
if steam_get_achievement("CLICK_THE_HOTDOG") { allach += 1 }
if steam_get_achievement("HM_MEDIUM") { allach += 1 }
if steam_get_achievement("HM_DIFFICULT") { allach += 1 }
if steam_get_achievement("HM_INSANE") { allach += 1 }
if steam_get_achievement("HM_RIDICULOUS") { allach += 1 }
if steam_get_achievement("HM_IMPOSSIBLE") { allach += 1 }
if steam_get_achievement("HM_YEAHGL") { allach += 1 }
if steam_get_achievement("HM_ETERNALSUFFERING") { allach += 1 }
if steam_get_achievement("SUPER_DETAILED_LEVEL") { allach += 1 }
if steam_get_achievement("EASTEREGG_2") { allach += 1 }
if steam_get_achievement("COOKIE_CLICKER") { allach += 1 }
if steam_get_achievement("LOW_ON_CREDITS") { allach += 1 }
if steam_get_achievement("TOO_MUCH_CREDITS") { allach += 1 }
if steam_get_achievement("KAIZO_CHALLENGE") { allach += 1 }
if steam_get_achievement("WORLD_1_QUICK") { allach += 1 }
if steam_get_achievement("WORLD_2_QUICK") { allach += 1 }
if steam_get_achievement("WORLD_3_QUICK") { allach += 1 }
if steam_get_achievement("WORLD_4_QUICK") { allach += 1 }
if steam_get_achievement("WORLD_5_QUICK") { allach += 1 }
if steam_get_achievement("JEBAITED") { allach += 1 }
if steam_get_achievement("CHECKPOINT") { allach += 1 }
if steam_get_achievement("WORLD_6") { allach += 1 }
if steam_get_achievement("WORLD_7") { allach += 1 }
if steam_get_achievement("ABSOLUTE_ENDLESS_HELL") { allach += 1 }
if steam_get_achievement("TORCHERD") { allach += 1 }
if steam_get_achievement("THE_REVERSE_PROBLEM") { allach += 1 }
if steam_get_achievement("A_FAN_OF_HATS") { allach += 1 }
if steam_get_achievement("HAT_COMPLETIONIST") { allach += 1 }
if steam_get_achievement("SKIN_COMPLETIONIST") { allach += 1 }
}