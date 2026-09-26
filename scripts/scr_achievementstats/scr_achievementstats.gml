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
if achievement_earned("IT_HAPPENED") { allach += 1 }
if achievement_earned("EASTER_EGG") { allach += 1 }
if achievement_earned("INVISIBLE_SKIN") { allach += 1 }
if achievement_earned("GRAYSCALE") { allach += 1 }
if achievement_earned("BOSS_KILL_1") { allach += 1 }
if achievement_earned("BOSS_KILL_2") { allach += 1 }
if achievement_earned("BOSS_KILL_3") { allach += 1 }
if achievement_earned("BOSS_KILL_4") { allach += 1 }
if achievement_earned("GOLDEN_SPIKE_DEATH") { allach += 1 }
if achievement_earned("WEIRD_SPIKE_DEATH") { allach += 1 }
if achievement_earned("FIRST_HAT") { allach += 1 }
if achievement_earned("FIRST_CHALLENGE") { allach += 1 }
if achievement_earned("PERFECT_CHALLENGE") { allach += 1 }
if achievement_earned("BRONZE_MEDAL") { allach += 1 }
if achievement_earned("SILVER_MEDAL") { allach += 1 }
if achievement_earned("GOLD_MEDAL") { allach += 1 }
if achievement_earned("DIAMOND_MEDAL") { allach += 1 }
if achievement_earned("DIAMOND_LOVER") { allach += 1 }
if achievement_earned("THE_ANTI_DEATH") { allach += 1 }
if achievement_earned("MAKE_LEVEL") { allach += 1 }
if achievement_earned("LOAD_LEVEL") { allach += 1 }
if achievement_earned("A_SMALL_LOAN") { allach += 1 }
if achievement_earned("MONEY_SAVER") { allach += 1 }
if achievement_earned("THE_GLITTERING_RICH") { allach += 1 }
if achievement_earned("BYE_BYE_LEVEL") { allach += 1 }
if achievement_earned("UH_OH") { allach += 1 }
if achievement_earned("ENDLESS_BEGINNER") { allach += 1 }
if achievement_earned("ENDLESS_RUNNER") { allach += 1 }
if achievement_earned("ENDLESS_EXPERT") { allach += 1 }
if achievement_earned("ENDLESS_MASTER") { allach += 1 }
if achievement_earned("YOUR_OWN_ENDLESS_RUN") { allach += 1 }
if achievement_earned("POTATO_SETTINGS") { allach += 1 }
if achievement_earned("BENCHMARK") { allach += 1 }
if achievement_earned("FLAG_GUY") { allach += 1 }
if achievement_earned("HAT_MERCHANT") { allach += 1 }
if achievement_earned("YOU_WIN") { allach += 1 }
if achievement_earned("OH_NO_THERES_MORE") { allach += 1 }
if achievement_earned("CLICK_THE_HOTDOG") { allach += 1 }
if achievement_earned("HM_MEDIUM") { allach += 1 }
if achievement_earned("HM_DIFFICULT") { allach += 1 }
if achievement_earned("HM_INSANE") { allach += 1 }
if achievement_earned("HM_RIDICULOUS") { allach += 1 }
if achievement_earned("HM_IMPOSSIBLE") { allach += 1 }
if achievement_earned("HM_YEAHGL") { allach += 1 }
if achievement_earned("THE_CROWN") { allach += 1 }
if achievement_earned("SUPER_DETAILED_LEVEL") { allach += 1 }
if achievement_earned("EASTEREGG_2") { allach += 1 }
if achievement_earned("COOKIE_CLICKER") { allach += 1 }
if achievement_earned("EASTEREGG_3") { allach += 1 }
if achievement_earned("EASTEREGG_4") { allach += 1 }
if achievement_earned("WORLD_WIDE_WEB") { allach += 1 }
if achievement_earned("WORLD_1_QUICK") { allach += 1 }
if achievement_earned("WORLD_2_QUICK") { allach += 1 }
if achievement_earned("WORLD_3_QUICK") { allach += 1 }
if achievement_earned("WORLD_4_QUICK") { allach += 1 }
if achievement_earned("WORLD_5_QUICK") { allach += 1 }
if achievement_earned("JEBAITED") { allach += 1 }
if achievement_earned("CHECKPOINT") { allach += 1 }
if achievement_earned("WORLD_6") { allach += 1 }
if achievement_earned("WORLD_7") { allach += 1 }
if achievement_earned("ABSOLUTE_ENDLESS_HELL") { allach += 1 }
if achievement_earned("TORCHERD") { allach += 1 }
if achievement_earned("THE_REVERSE_PROBLEM") { allach += 1 }
if achievement_earned("A_FAN_OF_HATS") { allach += 1 }
if achievement_earned("HAT_COMPLETIONIST") { allach += 1 }
if achievement_earned("SKIN_COMPLETIONIST") { allach += 1 }
if achievement_earned("TUTORIAL_CHALLENGE") { allach += 1 }
if achievement_earned("LADDER_CHALLENGE") { allach += 1 }
if achievement_earned("INVISIBLE_CHALLENGE") { allach += 1 }
if achievement_earned("BIGROOM_CHALLENGE") { allach += 1 }
if achievement_earned("SLIPPERY_CHALLENGE") { allach += 1 }
if achievement_earned("DOUBLEJUMP_CHALLENGE") { allach += 1 }
if achievement_earned("BLIND_CHALLENGE") { allach += 1 }
if achievement_earned("TROOP_CHALLENGE") { allach += 1 }
if achievement_earned("SPEED_CHALLENGE") { allach += 1 }
if achievement_earned("WATER_CHALLENGE") { allach += 1 }
if achievement_earned("MOVING_CHALLENGE") { allach += 1 }
if achievement_earned("BREAKABLE_CHALLENGE") { allach += 1 }
if achievement_earned("SPIKE_CHALLENGE") { allach += 1 }
if achievement_earned("COMMUNITY_CHALLENGE") { allach += 1 }
if achievement_earned("CORRUPTED_SPIKE_CHALLENGE") { allach += 1 }
if achievement_earned("WORKSHOP_BEGINNER") { allach += 1 }
if achievement_earned("WORKSHOP_MASTER") { allach += 1 }
if achievement_earned("PUBLISHER") { allach += 1 }
if achievement_earned("BOOTLEG_BR") { allach += 1 }
if achievement_earned("RACES_MULTI") { allach += 1 }
if achievement_earned("CALENDAR_EASY") { allach += 1 }
if achievement_earned("CALENDAR_MEDIUM") { allach += 1 }
if achievement_earned("CALENDAR_HARD") { allach += 1 }
if achievement_earned("SPINNNNN") { allach += 1 }
if achievement_earned("FEATURED_LEVEL") { allach += 1 }
if achievement_earned("DAILIES") { allach += 1 }
if achievement_earned("JACKPOT") { allach += 1 }
}
