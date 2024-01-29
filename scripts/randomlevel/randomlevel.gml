function randomlevel() {
	randomize()
	switch(global.endlessrunmode) {
	case(1):
	switch(global.difficultyER) {
	case(1): global.chooserandomlevel = choose(1,1,1,2,2,14,14,13,20) break;
	case(2): global.chooserandomlevel = choose(1,1,2,2,3,14,14,13,13,11,20,20,27) break;
	case(3): global.chooserandomlevel = choose(1,2,2,3,3,14,11,13,13,19,20,20,20,25,26,27) break;
	case(4): global.chooserandomlevel = choose(4,2,2,3,3,14,11,8,7,13,10,20,20,22,19,19,25,26,27) break;
	case(5): global.chooserandomlevel = choose(4,2,3,16,11,7,13,10,10,8,19,20,22,22,25,26,27) break;
	case(6): global.chooserandomlevel = choose(4,5,7,16,10,9,15,17,15,8,26,21,22,22,18,27) break;
	case(7): global.chooserandomlevel = choose(4,4,5,12,7,16,10,9,17,15,18,21,21,22,27) break;
	case(8): global.chooserandomlevel = choose(4,5,5,12,7,15,15,18,9,17,21,23) break;
	case(9): global.chooserandomlevel = choose(5,5,12,6,15,23,18) break;
	case(10): global.chooserandomlevel = choose(12,12,6,6,23,23,24) break;
	}
	break;
	case(2): 
	if global.endlesslevel < 50 {
	global.chooserandomlevel = choose(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27)
	} else {
	global.chooserandomlevel = irandom_range(1,27)
	}
	break;
	case(3):
	CERrandomlevel()
	break;
	}

	switch(global.chooserandomlevel) {
	case(1): scr_ERW1() break;
	case(2): scr_ERW2() break;
	case(3): scr_ERW3() break;
	case(4): scr_ERW4() break;
	case(5): scr_ERW5() break;
	case(6): scr_ERKaizo() break;
	case(7): scr_ERBlind() break;
	case(8): scr_ERBigRoom() break;
	case(9): scr_ERTroop() break;
	case(10): scr_ERSlippery() break;
	case(11): scr_ERSpeed() break;
	case(12): scr_ERW6() break;
	case(13): scr_ERLadder() break;
	case(14): scr_ERTutorial() break;
	case(15): scr_ERSpike() break;
	case(16): scr_ERWater() break;
	case(17): scr_ERMoving() break;
	case(18): scr_ERCommunity() break;
	case(19): scr_ERDJump() break;
	case(20): scr_ERC2021_E() break;
	case(21): scr_ERCSpike() break;
	case(22): scr_ERC2021_M() break;
	case(23): scr_ERC2021_H() break;
	case(24): scr_ERW7() break;
	case(25): scr_ERInvisible() break;
	case(26): scr_ERBreakable() break;
	case(27): scr_ERSpecialW1() break;
	}
	room_goto(global.chosenlevelER)
	
	//Difficulty
	if global.endlessrunmode = 1 {
	if global.difficultyER != 10 {
		if global.endlesslevel > 2 { global.difficultyincreaseER -= 1 }
	if global.difficultyincreaseER <= 0 {
		instance_create(x,y,o_difficultyupER)
		global.difficultyER += 1
		var mindiff = round(2 + (global.difficultyER / 2))
		var maxdiff = round(7 + (global.difficultyER / 3))
		global.difficultyincreaseER = irandom_range(mindiff,maxdiff)
		}
	} else {
	if global.cheats = 0 {
	if !steam_get_achievement("ABSOLUTE_ENDLESS_HELL") { steam_set_achievement("ABSOLUTE_ENDLESS_HELL") }
	}
	if global.skin032 = 0 {
	global.skin032 = 1
	scr_saveskins()
	}}}
	
	//Music
	global.endlessmusicchange -= 1
	global.endless1upchange -= 1
	
	if global.endless1upchange < 1 {
	if global.infinitelivessettings = 0 {
	global.hardmodelives += 1
	if global.endlessrunmode != 3 {global.endless1upchange = 10} else { global.endless1upchange = global.CER1upChange }
	
	}}
	
	if global.endlessmusicchange < 1 {
		if global.endlessrunmode != 3 {
	global.chooserandommusic = irandom_range(1,29)
		} else { CERrandommusic() }
	randomsong()
	audio_stop_all()
	audio_play_sound(global.chosenmusicER,0,1)
	if global.endlessrunmode != 3 { global.endlessmusicchange = 10 } else { global.endlessmusicchange = global.CERMusicChange }
	}


}
