function scr_checkachievements(){
if global.cheats = 1 { exit }
{
//LEVELS
if !achievement_earned("LEVEL_COMPLETION_1") { //BEAT 1 LEVEL
if global.totallevelcompleted > 0 { achievement_award("LEVEL_COMPLETION_1") }
}
if !achievement_earned("LEVEL_COMPLETION_2") { //BEAT 5 LEVEL
if global.totallevelcompleted > 4 { achievement_award("LEVEL_COMPLETION_2") }
}
if !achievement_earned("LEVEL_COMPLETION_3") { //BEAT 15 LEVEL
if global.totallevelcompleted > 14 { achievement_award("LEVEL_COMPLETION_3") }
}
if !achievement_earned("LEVEL_COMPLETION_4") { //BEAT 30 LEVEL
if global.totallevelcompleted > 29 { achievement_award("LEVEL_COMPLETION_4") }
}
if !achievement_earned("LEVEL_COMPLETION_5") { //BEAT 50 LEVEL
if global.totallevelcompleted > 49 { achievement_award("LEVEL_COMPLETION_5") }
}
if !achievement_earned("LEVEL_COMPLETION_6") { //BEAT 75 LEVEL
if global.totallevelcompleted > 74 { achievement_award("LEVEL_COMPLETION_6") }
}
if !achievement_earned("LEVEL_COMPLETION_7") { //BEAT 100 LEVEL
if global.totallevelcompleted > 99 { achievement_award("LEVEL_COMPLETION_7") }
}
if !achievement_earned("LEVEL_COMPLETION_8") { //BEAT 150 LEVEL
if global.totallevelcompleted > 149 { achievement_award("LEVEL_COMPLETION_8") }
}
if !achievement_earned("LEVEL_COMPLETION_9") { //BEAT 250 LEVEL
if global.totallevelcompleted > 249 { achievement_award("LEVEL_COMPLETION_9") }
}
if !achievement_earned("LEVEL_COMPLETION_10") { //BEAT 750 LEVEL
if global.totallevelcompleted > 749 { achievement_award("LEVEL_COMPLETION_10") }
}
if !achievement_earned("LEVEL_COMPLETION_11") { //BEAT 2500 LEVEL
if global.totallevelcompleted > 2499 { achievement_award("LEVEL_COMPLETION_11") }
}

//DEATHS
if !achievement_earned("DEATHS_1") { //DIE 1
if global.totaldeaths > 0 { achievement_award("DEATHS_1") }
}
if !achievement_earned("DEATHS_2") { //DIE 10
if global.totaldeaths >= 10 { achievement_award("DEATHS_2") }
}
if !achievement_earned("DEATHS_3") { //DIE 25
if global.totaldeaths >= 25 { achievement_award("DEATHS_3") }
}
if !achievement_earned("DEATHS_4") { //DIE 50
if global.totaldeaths >= 50 { achievement_award("DEATHS_4") }
}
if !achievement_earned("DEATHS_5") { //DIE 100
if global.totaldeaths >= 100 { achievement_award("DEATHS_5") }
}
if !achievement_earned("DEATHS_6") { //DIE 175
if global.totaldeaths >= 175 { achievement_award("DEATHS_6") }
}
if !achievement_earned("DEATHS_7") { //DIE 300
if global.totaldeaths >= 300 { achievement_award("DEATHS_7") }
}
if !achievement_earned("DEATHS_8") { //DIE 500
if global.totaldeaths >= 500 { achievement_award("DEATHS_8") }
}
if !achievement_earned("DEATHS_9") { //DIE 1000
if global.totaldeaths >= 1000 { achievement_award("DEATHS_9") }
}
if !achievement_earned("DEATHS_10") { //DIE 3000
if global.totaldeaths >= 3000 { achievement_award("DEATHS_10") }
}
if !achievement_earned("DEATHS_11") { //DIE 10000
if global.totaldeaths >= 10000 { achievement_award("DEATHS_11") }
}

//JUMPS
if !achievement_earned("JUMP_1") { //JUMP 1
if global.totaljumps > 0 { achievement_award("JUMP_1") }
}
if !achievement_earned("JUMP_2") { //JUMP 2
if global.totaljumps > 19 { achievement_award("JUMP_2") }
}
if !achievement_earned("JUMP_3") { //JUMP 3
if global.totaljumps > 99 { achievement_award("JUMP_3") }
}
if !achievement_earned("JUMP_4") { //JUMP 4
if global.totaljumps > 249 { achievement_award("JUMP_4") }
}
if !achievement_earned("JUMP_5") { //JUMP 5
if global.totaljumps > 999 { achievement_award("JUMP_5") }
}
if !achievement_earned("JUMP_6") { //JUMP 6
if global.totaljumps > 1999 { achievement_award("JUMP_6") }
}
if !achievement_earned("JUMP_7") { //JUMP 7
if global.totaljumps > 4999 { achievement_award("JUMP_7") }
}
if !achievement_earned("JUMP_8") { //JUMP 8
if global.totaljumps > 14999 { achievement_award("JUMP_8") }
}
if !achievement_earned("JUMP_9") { //JUMP 9
if global.totaljumps > 59999 { achievement_award("JUMP_9") }
}
if !achievement_earned("JUMP_10") { //JUMP 10
if global.totaljumps > 199999 { achievement_award("JUMP_10") }
}
if !achievement_earned("JUMP_11") { //JUMP 11
if global.totaljumps > 499999 { achievement_award("JUMP_11") }
}

//COINS
if !achievement_earned("COIN_1") { //COLLECT 1 COIN
if global.totalcoins > 0 { achievement_award("COIN_1") }
}
if !achievement_earned("COIN_2") { //COLLECT 5 COIN
if global.totalcoins >= 5 { achievement_award("COIN_2") }
}
if !achievement_earned("COIN_3") { //COLLECT 15 COIN
if global.totalcoins >= 15 { achievement_award("COIN_3") }
}
if !achievement_earned("COIN_4") { //COLLECT 30 COIN
if global.totalcoins >= 30 { achievement_award("COIN_4") }
}
if !achievement_earned("COIN_5") { //COLLECT 50 COIN
if global.totalcoins >= 50 { achievement_award("COIN_5") }
}
if !achievement_earned("COIN_6") { //COLLECT 75 COIN
if global.totalcoins >= 75 { achievement_award("COIN_6") }
}
if !achievement_earned("COIN_7") { //COLLECT 100 COIN
if global.totalcoins >= 100 { achievement_award("COIN_7") }
}
if !achievement_earned("COIN_8") { //COLLECT 150 COIN
if global.totalcoins >= 150 { achievement_award("COIN_8") }
}
if !achievement_earned("COIN_9") { //COLLECT 250 COIN
if global.totalcoins >= 250 { achievement_award("COIN_9") }
}
if !achievement_earned("COIN_10") { //COLLECT 750 COIN
if global.totalcoins >= 750 { achievement_award("COIN_10") }
}
if !achievement_earned("COIN_11") { //COLLECT 2500 COIN
if global.totalcoins >= 2500 { achievement_award("COIN_11") }
}

//BOSS
if !achievement_earned("BOSS_KILL_1") { //Boss 1
if room = r_boss1 {
if global.boss1 = 1 { achievement_award("BOSS_KILL_1") }}
}
if !achievement_earned("BOSS_KILL_2") { //Boss 2
if room = r_boss2 {
if global.boss2 = 1 { achievement_award("BOSS_KILL_2") }}
}
if !achievement_earned("BOSS_KILL_3") { //Boss 3
if room = r_boss3 {
if global.boss3 = 1 { achievement_award("BOSS_KILL_3") }}
}
if !achievement_earned("BOSS_KILL_4") { //Boss 4
if room = r_boss4 {
if global.boss4 = 1 { achievement_award("BOSS_KILL_4") }}
}

//CUSTOMIZATION
if !achievement_earned("FIRST_HAT") { //First Hat
if room = r_boss4 {
if global.boss4 = 1 { achievement_award("FIRST_HAT") }}
}

//SECRET
if !achievement_earned("EASTEREGG_1") { //An Egg?
if room = r_easteregg1 {
achievement_award("EASTEREGG_1")
}}

//HARD

//ENDLESS
if !achievement_earned("ENDLESS_BEGINNER") { //Endless Beginner (5)
	if global.endlesslevel >= 5 {
	if global.endlessrunmode != 3 {
	if global.endless = 1 {achievement_award("ENDLESS_BEGINNER") }
	}}}
if !achievement_earned("ENDLESS_RUNNER") { //Endless Runner (20)
	if global.endlesslevel >= 20 {
	if global.endlessrunmode != 3 {
	if global.endless = 1 {achievement_award("ENDLESS_RUNNER") }
	}}}
if !achievement_earned("ENDLESS_EXPERT") { //Endless Expert
	if global.endlesslevel >= 50 {
	if global.endlessrunmode != 3 {
	if global.endless = 1 {achievement_award("ENDLESS_EXPERT") }
	}}}
if !achievement_earned("ENDLESS_MASTER") { //Endless Master
	if global.endlesslevel >= 100 {
	if global.endlessrunmode != 3 {
	if global.endless = 1 {achievement_award("ENDLESS_MASTER") }
	}}}

} }
