if os_type = os_android || os_type = os_gxgames { instance_destroy() }
if global.hardmode = 1 { instance_destroy() 
exit;	
}
diff = 0
numerical = 0
if global.workshop = 1 {
lbname = string(global.Publish_ID)
} else {
switch(room) {
case(r_gameoverscreen):
if global.endlessrunmode = 1 { lbname = "Endless Run" }
if global.endlessrunmode = 2 { lbname = "Old School Endless Run" }
if global.hardmode = 1 { instance_destroy() }
numerical = 1
break;
case(r_kaizowin): lbname = "Kaizo Challenge Time" break;
case(r_blindwin): lbname = "Blind Challenge Time" break;
case(r_bigroomwin): lbname = "Big Room Challenge Time" break;
case(r_troopwin): lbname = "Troop Challenge Time" break;
case(r_slipperywin): lbname = "Slippery Challenge Time" break;
case(r_speedwin): lbname = "Speed Challenge Time" break;
case(r_world6win): lbname = "World 6 Challenge Time" break;
case(r_ladderwin): lbname = "Ladder Challenge Time" break;
case(r_tutorialwin): lbname = "Tutorial Challenge Time" break;
case(r_spikewin): lbname = "Spike Challenge Time" break;
case(r_waterwin): lbname = "Water Challenge Time" break;
case(r_movingwin): lbname = "Moving Challenge Time" break;
case(r_communitywin): lbname = "Community Challenge Time" break;
case(r_djwin): lbname = "DJ Challenge Time" break;
case(r_cswin): lbname = "Corrupted Spike Challenge Time" break;
case(r_world7win): lbname = "World 7 Challenge Time" break;
case(r_invisiblewin): lbname = "Invisible Challenge Time" break;
case(r_breakablewin): lbname = "Breakable Challenge Time" break;
case(r_endlessrunmenu): 
if diff = 0 {
lbname = "Endless Run 20L" 
} else {
lbname = "Endless Run 50L" 
} numerical = 1 break;
case(r_dailylevelwin): 
if diff = 0 {
lbname = "Daily Level Streak"
} else {
lbname = "Current Daily Level Streak"	
} numerical = 1 break;
}
}
reloadleaderboardsmini()
alarm[0] = 5
