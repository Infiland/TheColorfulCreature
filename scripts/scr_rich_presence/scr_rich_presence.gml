/// @function set_rich_presence()
/// @description Auto-detects current game state and sets Steam Rich Presence accordingly.
///              Uses localization tokens that map to rich_presence_localization.vdf.
///              Call this when entering menus or gameplay rooms.

function set_rich_presence() {
	// Only set rich presence if Steam is available
	if (!steam_initialised()) return;
	
	var _room = room;
	var _room_name = room_get_name(_room);
	
	// ========================================
	// MENU ROOMS - Check room directly
	// ========================================
	
	if (_room == r_mainmenu) {
		steam_set_rich_presence("steam_display", "#MainMenu");
		return;
	}
	
	if (_room == r_gamemode) {
		steam_set_rich_presence("steam_display", "#GameModeMenu");
		return;
	}
	
	if (_room == r_funmodemenu) {
		steam_set_rich_presence("steam_display", "#FunModeMenu");
		return;
	}
	
	if (_room == r_settings) {
		steam_set_rich_presence("steam_display", "#Settings");
		return;
	}
	
	if (_room == r_challenges) {
		steam_set_rich_presence("steam_display", "#ChallengesMenu");
		return;
	}
	
	if (_room == r_endlessrunmenu) {
		steam_set_rich_presence("steam_display", "#EndlessRunMenu");
		return;
	}
	
	if (_room == r_customlevelmenu) {
		steam_set_rich_presence("steam_display", "#CustomLevelsMenu");
		return;
	}
	
	if (_room == r_calendar) {
		steam_set_rich_presence("steam_display", "#CalendarMenu");
		return;
	}
	
	if (_room == r_levelselectmenu) {
		steam_set_rich_presence("steam_display", "#LevelSelectMenu");
		return;
	}
	
	if (_room == r_skinmenu) {
		steam_set_rich_presence("steam_display", "#Customizing");
		return;
	}
	
	if (_room == r_localmultiplayermenu) {
		steam_set_rich_presence("steam_display", "#MultiplayerMenu");
		return;
	}
	
	if (_room == r_workshopchallengemenu) {
		steam_set_rich_presence("steam_display", "#WorkshopChallengeMenu");
		return;
	}
	
	if (_room == r_onlineleaderboard) {
		steam_set_rich_presence("steam_display", "#Leaderboards");
		return;
	}
	
	if (_room == r_stats) {
		steam_set_rich_presence("steam_display", "#Stats");
		return;
	}
	
	if (_room == r_achievements) {
		steam_set_rich_presence("steam_display", "#Achievements");
		return;
	}
	
	if (_room == r_credits) {
		steam_set_rich_presence("steam_display", "#Credits");
		return;
	}
	
	if (_room == r_soundtestmenu) {
		steam_set_rich_presence("steam_display", "#SoundTest");
		return;
	}
	
	if (_room == r_hatmerchantroom) {
		steam_set_rich_presence("steam_display", "#HatShop");
		return;
	}
	
	if (_room == r_support) {
		steam_set_rich_presence("steam_display", "#MainMenu");
		return;
	}
	
	if (_room == r_iapjoke) {
		steam_set_rich_presence("steam_display", "#MainMenu");
		return;
	}
	
	// ========================================
	// LEVEL EDITOR
	// ========================================
	
	if (_room == r_leveleditor || _room == r_oldleveleditor) {
		if (variable_global_exists("levelname") && global.levelname != "") {
			steam_set_rich_presence("levelname", global.levelname);
			steam_set_rich_presence("steam_display", "#LevelEditorNamed");
		} else {
			steam_set_rich_presence("steam_display", "#LevelEditor");
		}
		return;
	}
	
	// ========================================
	// GAME OVER SCREEN
	// ========================================
	
	if (_room == r_gameoverscreen) {
		steam_set_rich_presence("level", string(global.endlesslevel));
		steam_set_rich_presence("steam_display", "#GameOver");
		return;
	}
	
	// ========================================
	// LOCAL MULTIPLAYER (Race / Survival rooms)
	// ========================================
	
	if (string_pos("r_MUrace", _room_name) == 1 || string_pos("r_MUSurvival", _room_name) == 1) {
		steam_set_rich_presence("steam_display", "#LocalMultiplayer");
		return;
	}
	
	// ========================================
	// GAMEPLAY STATES - Check global flags
	// ========================================
	
	// --- Endless Run ---
	if (global.endless == 1) {
		steam_set_rich_presence("level", string(global.endlesslevel));
		
		switch (global.endlessrunmode) {
			case 1:
				steam_set_rich_presence("steam_display", "#EndlessRun");
				break;
			case 2:
				steam_set_rich_presence("steam_display", "#OldEndlessRun");
				break;
			case 3:
				steam_set_rich_presence("steam_display", "#CustomEndlessRun");
				break;
			default:
				steam_set_rich_presence("steam_display", "#EndlessRun");
				break;
		}
		return;
	}
	
	// --- Challenges ---
	if (global.challenges == 1) {
		var _challenge_name = "";
		var _def = scr_challenge_get_def(global.currentchallenge);
		if (!is_undefined(_def)) {
			_challenge_name = scr_challenge_get_title(_def);
		}
		if (_challenge_name == "") {
			_challenge_name = "Unknown";
		}
		steam_set_rich_presence("challengename", _challenge_name);
		steam_set_rich_presence("steam_display", "#PlayingChallenge");
		return;
	}
	
	// --- Daily Level ---
	if (global.dailylevel == 1) {
		steam_set_rich_presence("steam_display", "#DailyLevel");
		return;
	}
	
	// --- Calendar Mode ---
	if (global.calendar >= 1) {
		steam_set_rich_presence("steam_display", "#Calendar");
		return;
	}
	
	// --- Workshop Challenge ---
	if (global.workshopchallenge == 1) {
		var _wc_name = "";
		if (variable_global_exists("workshopchallenge_title")) {
			_wc_name = global.workshopchallenge_title;
		}
		if (_wc_name == "") _wc_name = "Workshop Challenge";
		steam_set_rich_presence("levelname", _wc_name);
		steam_set_rich_presence("steam_display", "#WorkshopChallenge");
		return;
	}
	
	// --- Workshop Level ---
	if (global.workshop == 1) {
		var _ws_name = "";
		if (variable_global_exists("levelname")) {
			_ws_name = global.levelname;
		}
		if (_ws_name == "") _ws_name = "Custom Level";
		steam_set_rich_presence("levelname", _ws_name);
		steam_set_rich_presence("steam_display", "#WorkshopLevel");
		return;
	}
	
	// --- Boss Fights ---
	if (_room == r_boss1 || _room == r_boss1prepare) {
		steam_set_rich_presence("boss", "1");
		steam_set_rich_presence("steam_display", "#FightingBoss");
		return;
	}
	if (_room == r_boss2 || _room == r_boss2prepare) {
		steam_set_rich_presence("boss", "2");
		steam_set_rich_presence("steam_display", "#FightingBoss");
		return;
	}
	if (_room == r_boss3 || _room == r_boss3prepare) {
		steam_set_rich_presence("boss", "3");
		steam_set_rich_presence("steam_display", "#FightingBoss");
		return;
	}
	if (_room == r_boss4 || _room == r_boss4prepare) {
		steam_set_rich_presence("boss", "4");
		steam_set_rich_presence("steam_display", "#FightingBoss");
		return;
	}
	if (_room == r_boss5) {
		steam_set_rich_presence("boss", "5");
		steam_set_rich_presence("steam_display", "#FightingBoss");
		return;
	}
	
	// --- World 6 ---
	if (string_pos("r_world6lvl", _room_name) == 1) {
		var _lvl_num = string_delete(_room_name, 1, string_length("r_world6lvl"));
		steam_set_rich_presence("level", _lvl_num);
		steam_set_rich_presence("steam_display", "#World6");
		return;
	}
	
	// --- World 7 ---
	if (string_pos("r_world7lvl", _room_name) == 1) {
		var _lvl_num = string_delete(_room_name, 1, string_length("r_world7lvl"));
		steam_set_rich_presence("level", _lvl_num);
		steam_set_rich_presence("steam_display", "#World7");
		return;
	}
	
	// --- Level Select Mode ---
	if (global.levelselect == 1) {
		// Extract level number from room name (r_lvl1 through r_lvl100)
		var _lvl_num = _rich_presence_get_level_number(_room_name);
		if (_lvl_num != "") {
			steam_set_rich_presence("level", _lvl_num);
			steam_set_rich_presence("steam_display", "#LevelSelect");
			return;
		}
	}
	
	// --- Hard Mode ---
	if (global.hardmode == 1) {
		var _lvl_num = _rich_presence_get_level_number(_room_name);
		if (_lvl_num != "") {
			steam_set_rich_presence("level", _lvl_num);
			steam_set_rich_presence("steam_display", "#PlayingLevelHard");
			return;
		}
	}
	
	// --- Main Campaign Levels (r_lvl1 through r_lvl100) ---
	var _lvl_num = _rich_presence_get_level_number(_room_name);
	if (_lvl_num != "") {
		steam_set_rich_presence("level", _lvl_num);
		steam_set_rich_presence("steam_display", "#PlayingLevel");
		return;
	}
	
	// --- True Level 100 ---
	if (string_pos("r_truelvl100", _room_name) == 1) {
		steam_set_rich_presence("level", "100");
		steam_set_rich_presence("steam_display", "#PlayingLevel");
		return;
	}
	
	// --- Challenge Win / Ending rooms ---
	if (_room == r_theend || _room == r_fakeending) {
		steam_set_rich_presence("steam_display", "#Credits");
		return;
	}
	
	// --- Tale / Story rooms ---
	if (_room == r_tale || _room == r_taleroom) {
		steam_set_rich_presence("steam_display", "#PlayingLevel");
		steam_set_rich_presence("level", "???");
		return;
	}
	
	// --- Loading / Intro (treat as main menu) ---
	if (_room == r_loading || _room == r_logointro) {
		steam_set_rich_presence("steam_display", "#MainMenu");
		return;
	}
	
	// --- Demo finished screen ---
	if (_room == r_demofinishedscreen) {
		steam_set_rich_presence("steam_display", "#MainMenu");
		return;
	}
	
	// --- Hard Mode Death Room ---
	if (_room == r_hardmodedeathroom) {
		steam_set_rich_presence("steam_display", "#GameOver");
		steam_set_rich_presence("level", "0");
		return;
	}
	
	// --- Fallback for any challenge level rooms ---
	// These include r_tutoriallvl*, r_ladderlvl*, r_bigroomlvl*, r_slipperylvl*, etc.
	if (global.challenges == 1 || string_pos("lvl", _room_name) > 0) {
		if (global.currentchallenge != 0) {
			var _def = scr_challenge_get_def(global.currentchallenge);
			if (!is_undefined(_def)) {
				steam_set_rich_presence("challengename", scr_challenge_get_title(_def));
				steam_set_rich_presence("steam_display", "#PlayingChallenge");
				return;
			}
		}
	}
	
	// --- Daily level win / Workshop level win ---
	if (_room == r_dailylevelwin) {
		steam_set_rich_presence("steam_display", "#DailyLevel");
		return;
	}
	if (_room == r_workshoplevelwin) {
		var _ws_name = "";
		if (variable_global_exists("levelname")) _ws_name = global.levelname;
		if (_ws_name == "") _ws_name = "Custom Level";
		steam_set_rich_presence("levelname", _ws_name);
		steam_set_rich_presence("steam_display", "#WorkshopLevel");
		return;
	}
	
	// ========================================
	// ULTIMATE FALLBACK
	// ========================================
	steam_set_rich_presence("steam_display", "#MainMenu");
}


/// @function _rich_presence_get_level_number(room_name)
/// @description Helper to extract level number from room names like "r_lvl1" through "r_lvl100"
/// @param {string} room_name The name of the room
/// @returns {string} The level number as a string, or "" if not a main level room
function _rich_presence_get_level_number(_room_name) {
	if (string_pos("r_lvl", _room_name) == 1) {
		var _num_str = string_delete(_room_name, 1, string_length("r_lvl"));
		// Verify it's a number
		if (string_length(_num_str) > 0 && string_digits(_num_str) == _num_str) {
			return _num_str;
		}
	}
	return "";
}
