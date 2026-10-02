function scr_savegame(_save_room = undefined, _save_directory = "") {
    if ((platform_steam() && tcc_steam_get_app_id() == 1749610) || global.hardmode
        || global.challenges || global.endless || global.cheats || global.workshop
        || global.calendar || global.levelselect || global.dailylevel) return false;
	var directory = _save_directory == "" ? directory_set("//Save Files/") : _save_directory;
	if (is_undefined(_save_room)) _save_room = room;
	if (_save_room == -1 || asset_get_type(_save_room) != asset_room) return false;

	var SavedRoom = room_get_name(_save_room);

	if (scr_saved_room(SavedRoom) == -1) return false;
	if (!directory_exists(directory)) directory_create(directory);
	scr_save_begin(directory + "SaveFile.sav");
	ini_write_real("SaveFile Information","Deaths",global.deaths);
	// Restarting a room restores its coin, just like death. Only banked coins
	// survive a resume; a completed door or converter has already cleared pickup.
	ini_write_real("SaveFile Information","Coins",max(0, global.special - (global.pickup == 1 ? 1 : 0)));
	ini_write_real("SaveFile Information","Time",global.time);
	ini_write_real("SaveFile Information","Check Deposit",global.checkdeposit);
	ini_write_real("SaveFile Information","Boss One",global.boss1);
	ini_write_real("SaveFile Information","Boss Two",global.boss2);
	ini_write_real("SaveFile Information","Boss Three",global.boss3);
	ini_write_real("SaveFile Information","Boss Four",global.boss4);
	ini_write_real("SaveFile Information","Boss Five",global.boss5);
	ini_write_real("SaveFile Information","World 1 Time",global.world1time);
	ini_write_real("SaveFile Information","World 2 Time",global.world2time);
	ini_write_real("SaveFile Information","World 3 Time",global.world3time);
	ini_write_real("SaveFile Information","World 4 Time",global.world4time);
	ini_write_real("SaveFile Information","World 5 Time",global.world5time);
	ini_write_string("SaveFile Information","Level",SavedRoom);
	return scr_save_finish(directory + "SaveFile.sav");

}

/// Campaign entry must not inherit practice, challenge or multiplayer routing.
/// Keep preferences, unlocks and the counters read from the campaign save.
function scr_campaign_reset_context() {
    scr_workshopchallenge_abort();
    scr_resetcheckpointdata();
    level_music_release();
    global.levelselect = 0;
    global.challenges = 0;
    global.endless = 0;
    global.workshop = 0;
    global.workshopchallenge = 0;
    global.calendar = 0;
    global.dailylevel = 0;
    global.hardmode = 0;
    global.pause = 0;
    global.pickup = 0;
    global.challenge_run_id = -1;
    global.currentchallenge = -1;
    global.challenge_custom = false;
    global.challenge_level_dir = "";
    global.challenge_level_index = 0;
    global.challenge_room_index = 0;
    global.level_document_context = "";
    global.workshopchallenge_return_to_creator = 0;
    global.workshopfolder = "";
    global.chooseminigameMU = false;
    global.MinigameMU = 0;
}

/// Real INI transactions in the Check profile; no room transitions or services.
function scr_campaign_save_selfcheck() {
    var _assert = function(_ok, _why) { if (!_ok) throw "Campaign save self-check: " + _why; };
    var _flags = ["hardmode", "challenges", "endless", "cheats", "workshop", "calendar", "levelselect", "dailylevel"];
    var _counters = ["deaths", "special", "time", "checkdeposit", "boss1", "boss2", "boss3", "boss4", "boss5",
        "world1time", "world2time", "world3time", "world4time", "world5time"];
    var _transient = ["workshopchallenge", "pause", "pickup", "challenge_run_id", "currentchallenge", "challenge_custom",
        "challenge_level_dir", "challenge_level_index", "challenge_room_index", "level_document_context",
        "workshopchallenge_return_to_creator", "workshopfolder", "chooseminigameMU", "MinigameMU",
        "checkpointX", "checkpointY", "checkpointCOLOR", "checkpointGRV", "checkpointAMMO", "checkpointGUN",
        "level_music_stream", "hatmerchantdiscount", "worldProgression", "controlsmoveleft",
        "workshopchallenge_title", "workshopchallenge_levels", "workshopchallenge_index", "workshopchallenge_diamond_time",
        "workshopchallenge_difficulty", "workshopchallenge_signature", "workshopchallenge_is_draft"];
    var _names = array_concat(_flags, _counters, _transient), _previous = [];
    for (var _i = 0; _i < array_length(_names); ++_i) {
        array_push(_previous, variable_global_exists(_names[_i]) ? variable_global_get(_names[_i]) : undefined);
    }
    var _directory = game_save_id + "/PortSelfCheck/CampaignResume_" + string(current_time) + "/";
    directory_create(game_save_id + "/PortSelfCheck/");
    directory_create(_directory);
    var _file = _directory + "SaveFile.sav", _preserved = _directory + "Preserved.sav";
    for (var _i = 0; _i < array_length(_flags); ++_i) variable_global_set(_flags[_i], 0);
    for (var _i = 0; _i < array_length(_counters); ++_i) variable_global_set(_counters[_i], 0);
    global.pickup = 0;
    global.deaths = 12;
    global.time = 123.25;
    global.special = 7;
    global.boss1 = 1;
    global.world1time = 42.5;
    global.worldProgression = 30;
    _assert(room_next(r_lvl30) == r_hatmerchantroom && room_next(r_hatmerchantroom) == r_lvl31,
        "actual campaign transition preserves the merchant between 30 and 31");
    _assert(scr_savegame(r_lvl30, _directory), "stage 30 campaign save succeeds");
    global.worldProgression = 31;
    global.special = 8; // The outgoing door has banked its collected coin.
    _assert(scr_savegame(room_next(r_lvl30), _directory), "door saves its actual merchant destination");
    ini_open(_file);
    var _saved_room = ini_read_string("SaveFile Information", "Level", "");
    ini_close();
    _assert(scr_saved_room(_saved_room) == r_hatmerchantroom, "merchant room name round trips without shifting indices");

    file_copy(_file, _preserved);
    global.levelselect = 1;
    global.special = 999;
    _assert(!scr_savegame(r_lvl31, _directory) && scr_files_equal(_file, _preserved), "practice cannot replace campaign progress");
    global.workshopchallenge = 1; global.workshop = 1; global.challenges = 1;
    global.endless = 1; global.calendar = 1; global.dailylevel = 1; global.hardmode = 1;
    global.chooseminigameMU = true; global.MinigameMU = 2;
    global.pause = 1; global.pickup = 1; global.cheats = 1;
    global.checkpointX = 456; global.checkpointY = 789;
    global.checkpointCOLOR = 3; global.checkpointGRV = 1.5; global.checkpointAMMO = 99; global.checkpointGUN = true;
    global.challenge_run_id = 19; global.currentchallenge = 19;
    global.challenge_custom = true; global.challenge_level_dir = "Lunar Base Challenge/1";
    global.challenge_level_index = 2; global.challenge_room_index = 3;
    global.level_document_context = "workshop"; global.workshopchallenge_return_to_creator = 1;
    global.controlsmoveleft = "37";
    _assert(scr_loadgame(_directory, false), "actual campaign loader accepts saved merchant");
    _assert(global.deaths == 12 && global.time == 123.25 && global.special == 8 && global.boss1 == 1 && global.world1time == 42.5,
        "loaded counters survive the context reset");
    _assert(global.worldProgression == 31 && global.cheats == 1 && global.controlsmoveleft == "37", "unlocks and user preferences survive campaign entry");
    for (var _i = 0; _i < array_length(_flags); ++_i) {
        if (_flags[_i] != "cheats") _assert(variable_global_get(_flags[_i]) == 0, "campaign entry clears " + _flags[_i]);
    }
    _assert(global.workshopchallenge == 0 && !global.chooseminigameMU && global.MinigameMU == 0 && global.pause == 0 && global.pickup == 0,
        "campaign entry clears retry and multiplayer routing");
    _assert(global.challenge_run_id == -1 && global.currentchallenge == -1 && !global.challenge_custom
        && global.challenge_level_dir == "" && global.challenge_level_index == 0 && global.challenge_room_index == 0
        && global.level_document_context == "" && global.workshopchallenge_return_to_creator == 0,
        "campaign entry clears packaged and Workshop run ownership");
    _assert(global.checkpointX == 0 && global.checkpointY == 0 && global.checkpointCOLOR == -1 && global.checkpointGRV == 0
        && global.checkpointAMMO == 0 && !global.checkpointGUN, "campaign resume starts at its room spawn");
    global.cheats = 0;
    global.special = 9; global.pickup = 1;
    _assert(scr_savegame(r_hatmerchantroom, _directory) && scr_loadgame(_directory, false), "interrupted pickup reloads through real save/load");
    _assert(global.special == 8 && global.pickup == 0, "provisional coin is neither duplicated nor deducted twice on resume");
    global.special = 9; global.pickup = 1;
    _assert(scr_savegame(r_hatmerchantroom, _directory), "direct restart saves before its provisional rollback");
    global.special -= 1; global.pickup = 0; // Existing Player Create/death rollback.
    _assert(scr_savegame(r_hatmerchantroom, _directory) && scr_loadgame(_directory, false) && global.special == 8,
        "death/restart rollback is saved once");
    global.special = 0; global.pickup = 0; global.checkdeposit = true;
    _assert(scr_savegame(r_hatmerchantroom, _directory) && scr_loadgame(_directory, false)
        && global.special == 0 && global.checkdeposit, "converted coins and deposit-once state survive resume");
    global.special = 9; global.pickup = 0;
    _assert(scr_savegame(room_next(r_hatmerchantroom), _directory), "normal campaign autosaving works again after practice");
    ini_open(_file);
    _saved_room = ini_read_string("SaveFile Information", "Level", "");
    ini_close();
    _assert(scr_saved_room(_saved_room) == r_lvl31 && scr_loadgame(_directory, false) && global.special == 9, "stage 31 and committed coin resume exactly");

    scr_save_begin(_file);
    ini_write_string("SaveFile Information", "Level", "r_leveleditor");
    ini_write_real("SaveFile Information", "Deaths", 999);
    _assert(scr_save_finish(_file), "invalid room fixture written");
    file_delete(_preserved); file_copy(_file, _preserved);
    global.deaths = 314; global.levelselect = 1; global.checkpointX = 123;
    _assert(!scr_loadgame(_directory, false) && global.deaths == 314 && global.levelselect == 1 && global.checkpointX == 123
        && scr_files_equal(_file, _preserved), "invalid saves keep both file and prior session state");
    for (var _i = 0; _i < array_length(_names); ++_i) variable_global_set(_names[_i], _previous[_i]);
    return true;
}
