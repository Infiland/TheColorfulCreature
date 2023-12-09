image_alpha = 1
switch(challenge) {
case(0): //Tutorial
medalcheck(global.tutorialchallengetime,36)
break;
case(1): //Ladder
medalcheck(global.ladderchallengetime,46)
break;
case(2): //Big Room
medalcheck(global.bigroomchallengetime,150)
break;
case(3): //Slippery Blocks
medalcheck(global.slipperychallengetime,127.2)
break;
case(4): //Can't see shit challenge
medalcheck(global.blindchallengetime,194.2)
break;
case(5): //Troop
medalcheck(global.troopchallengetime,55)
break;
case(6): //Speed
medalcheck(global.speedchallengetime,105)
break;
case(7): //Spike
medalcheck(global.spikechallengetime,135)
break;
case(8): //Kaizo
medalcheck(global.kaizochallengetime,444)
break;
case(9): //World Six
medalcheck(global.world6challengetime,191.6)
break;
case(10): //Water
medalcheck(global.waterchallengetime,101.2)
break;
case(11): //Moving
medalcheck(global.movingchallengetime,94.5)
break;
case(12): //Community
medalcheck(global.communitychallengetime,183.2)
break;
case(13): //Double Jump
medalcheck(global.djumpchallengetime,57.1)
break;
case(14): //Corrupted Spike Challenge
medalcheck(global.cspikechallengetime,205)
break;
case(15): //World 7
medalcheck(global.world7challengetime,2097.9)
break;
case(16): //Invisible
medalcheck(global.invisiblechallengetime,60)
break;
case(17): //BBreakable
medalcheck(global.breakablechallengetime,58.5)
break;
}

if deaths = 0 {
	global.perfectscorecount += 1
	if !steam_get_achievement("PERFECT_CHALLENGE") { steam_set_achievement("PERFECT_CHALLENGE") }
	if global.perfectscorecount > 4 {
		if !steam_get_achievement("THE_ANTI_DEATH") { steam_set_achievement("THE_ANTI_DEATH") }
	}}