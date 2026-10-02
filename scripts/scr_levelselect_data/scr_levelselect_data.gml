/// The catalog is also the launch contract: packaged levels keep their sequence
/// index and directory, rather than pretending every challenge is a room prefix.
function levelselect_entry(_room, _music, _number, _challenge = -1, _directory = "", _sequence = 0) {
    return {text:string(_number), roomselect:_room, levelmusic:_music, level_num:_number,
        is_challenge:(_challenge >= 0), challenge_id:_challenge, level_dir:_directory,
        sequence_index:_sequence};
}

function levelselect_room_valid(_asset) {
    return _asset != -1 && asset_get_type(_asset) == asset_room;
}

function get_levelselect_pages() {
    var _pages = [];
    array_push(_pages, build_world_page("World 1", 1, 20, m_basics));
    array_push(_pages, build_world_page("World 2", 21, 40, m_owthespikes));
    array_push(_pages, build_world_page("World 3", 41, 60, m_everythingismoving));
    array_push(_pages, build_world_page_w4());
    array_push(_pages, build_world_page("World 5", 81, 100, m_thecastle));
    if (variable_global_exists("challenge_order")) {
        for (var _i = 0; _i < ds_list_size(global.challenge_order); ++_i) {
            var _def = scr_challenge_get_def(global.challenge_order[| _i]);
            if (is_undefined(_def) || _def.enabled != 1) continue;
            var _page = build_challenge_page(_def);
            var _count = array_length(_page.levels);
            // Forty buttons fit the view. Longer custom sequences get real pages.
            for (var _start = 0; _start < _count; _start += 40) {
                var _chunk = {title:_page.title, levels:[], is_world:false, challenge_id:_def.id};
                if (_count > 40) _chunk.title += "  " + string(1 + (_start div 40)) + "/" + string(ceil(_count / 40));
                for (var _j = _start; _j < min(_start + 40, _count); ++_j) array_push(_chunk.levels, _page.levels[_j]);
                array_push(_pages, _chunk);
            }
        }
    }
    return _pages;
}

function build_world_page(_title, _start, _end, _music) {
    var _page = {title:_title, levels:[], is_world:true, challenge_id:-1};
    for (var _i = _start; _i <= _end; ++_i) {
        var _room = asset_get_index("r_lvl" + string(_i));
        if (levelselect_room_valid(_room)) array_push(_page.levels, levelselect_entry(_room, _music, _i));
    }
    return _page;
}

function build_world_page_w4() {
    var _page = build_world_page("World 4", 61, 80, m_corruptedworld);
    for (var _i = 0; _i < array_length(_page.levels); ++_i) {
        var _level = _page.levels[_i];
        if (_level.level_num == 69) _level.levelmusic = m_breakfromcorruption;
        else if (_level.level_num > 69) _level.levelmusic = m_lesscorruption;
    }
    return _page;
}

function build_challenge_page(_def) {
    var _page = {title:scr_challenge_get_title(_def), levels:[], is_world:false, challenge_id:_def.id};
    var _music = asset_get_index(_def.music);
    if (_music != -1 && asset_get_type(_music) != asset_sound) _music = -1;
    if (array_length(_def.level_dirs) > 0) {
        for (var _i = 0; _i < array_length(_def.level_dirs); ++_i) {
            if (_def.level_dirs[_i] == "") continue;
            array_push(_page.levels, levelselect_entry(r_challengelevel, _music, _i + 1, _def.id, _def.level_dirs[_i], _i));
        }
    } else if (array_length(_def.rooms) > 0) {
        for (var _i = 0; _i < array_length(_def.rooms); ++_i) {
            var _room = asset_get_index(_def.rooms[_i]);
            if (levelselect_room_valid(_room)) array_push(_page.levels, levelselect_entry(_room, _music, _i + 1, _def.id, "", _i));
        }
    } else if (_def.room != "") {
        var _position = string_pos("lvl", _def.room);
        if (_position > 0) {
            var _prefix = string_copy(_def.room, 1, _position + 2);
            for (var _number = 1; _number <= 1000; ++_number) {
                var _room = asset_get_index(_prefix + string(_number));
                if (!levelselect_room_valid(_room)) break;
                array_push(_page.levels, levelselect_entry(_room, _music, _number, _def.id, "", _number - 1));
            }
        }
        // A real singleton room does not need an artificial "lvl1" suffix.
        if (array_length(_page.levels) == 0) {
            var _room = asset_get_index(_def.room);
            if (levelselect_room_valid(_room)) array_push(_page.levels, levelselect_entry(_room, _music, 1, _def.id));
        }
    }
    return _page;
}

function levelselect_unlocked(_entry) {
    if (_entry.is_challenge) {
        var _def = scr_challenge_get_def(_entry.challenge_id);
        return !is_undefined(_def) && _def.enabled == 1 && scr_challenge_is_unlocked(_def);
    }
    return global.worldProgression >= _entry.level_num;
}

function levelselect_hardmode_available() {
    return variable_global_exists("hardmodeunlock") && global.hardmodeunlock >= 1;
}

function levelselect_start(_entry) {
    if (!is_struct(_entry) || !levelselect_room_valid(_entry.roomselect) || !levelselect_unlocked(_entry)) return false;
    if (tcc_steam_get_app_id() == 1749610) {
        if (!instance_exists(o_demoask)) instance_create(0, 0, o_demoask);
        return false;
    }
    global.levelselect = 1;
    global.challenge_run_id = -1;
    global.workshop = 0;
    global.workshopchallenge = 0;
    global.endless = 0;
    global.dailylevel = 0;
    global.calendar = 0;
    global.pause = 0;
    global.time = 0;
    global.deaths = 0;
    global.pickup = 0;
    global.hatmerchantdiscount = 1.3333333333333;
    if (!levelselect_hardmode_available()) global.hardmode = 0;
    scr_resetcheckpointdata();
    global.challenges = _entry.is_challenge ? 1 : 0;
    global.challenge_custom = false;
    global.challenge_level_dir = "";
    global.challenge_level_index = 0;
    global.challenge_room_index = 0;
    if (_entry.is_challenge) {
        var _def = scr_challenge_get_def(_entry.challenge_id);
        global.currentchallenge = _entry.challenge_id;
        global.DiamondMedalTimeChallenge = _def.diamond_time;
        global.challenge_custom = _def.is_custom;
        if (_entry.level_dir != "") {
            if (!scr_challenge_prepare_custom_level(_def, _entry.level_dir)) return false;
            global.challenge_level_index = _entry.sequence_index;
        } else {
            global.challenge_room_index = _entry.sequence_index;
        }
        scr_challenge_play_music(_def);
    } else {
        global.currentchallenge = -1;
        level_music_release();
        audio_stop_all();
        if (_entry.levelmusic != -1) audio_play_sound(_entry.levelmusic, 0, 1);
    }
    // Set this again after adapters: no level-select entry can authorize full-run
    // records, achievements, medals or rewards, even at the challenge's last door.
    global.levelselect = 1;
    global.challenge_run_id = -1;
    loadhud();
    window_set_cursor(cr_default);
    room_goto(_entry.roomselect);
    return true;
}

function levelselect_selfcheck() {
    var _assert = function(_ok, _why) { if (!_ok) throw "Level select self-check: " + _why; };
    var _pages = get_levelselect_pages();
    var _campaign = 0;
    var _lunar = false;
    var _seen = {};
    for (var _p = 0; _p < array_length(_pages); ++_p) {
        var _page = _pages[_p];
        _assert(array_length(_page.levels) <= 40, "buttons fit on one page");
        for (var _i = 0; _i < array_length(_page.levels); ++_i) {
            var _entry = _page.levels[_i];
            _assert(levelselect_room_valid(_entry.roomselect), "catalog contains only actual rooms");
            if (!_entry.is_challenge) {
                var _key = string(_entry.level_num);
                _assert(!variable_struct_exists(_seen, _key), "campaign level appears once");
                variable_struct_set(_seen, _key, true);
                _campaign++;
            } else if (_entry.challenge_id == 19) {
                _lunar = _entry.roomselect == r_challengelevel && _entry.level_dir == "Lunar Base Challenge/1" && _entry.sequence_index == 0;
            }
        }
    }
    _assert(_campaign == 100, "all 100 campaign levels covered");
    // The reported World 2 state must keep real labels across its unlock boundary.
    var _world2 = _pages[1];
    _assert(_world2.is_world && array_length(_world2.levels) == 20, "World 2 has twenty campaign entries");
    var _old_progression = variable_global_exists("worldProgression") ? global.worldProgression : 1;
    global.worldProgression = 31;
    var _world2_unlocked = 0;
    for (var _i = 0; _i < 20; ++_i) {
        var _entry = _world2.levels[_i];
        var _number = 21 + _i;
        _assert(_entry.level_num == _number && _entry.roomselect == asset_get_index("r_lvl" + string(_number)), "World 2 retains absolute room/progression indices");
        _assert(_entry.text == string(_number), "World 2 labels stay numeric, including locked entries");
        var _unlocked = levelselect_unlocked(_entry);
        _assert(_unlocked == (_number <= 31), "World 2 unlock boundary uses campaign progression");
        if (_unlocked) _world2_unlocked += 1;
    }
    global.worldProgression = _old_progression;
    _assert(_world2_unlocked == 11 && 20 - _world2_unlocked == 9, "World 2 progression 31 gives eleven unlocked and nine locked");
    _assert(_lunar, "packaged Lunar level covered regardless of current unlock");
    var _base = scr_challenge_get_def(19);
    var _singleton = json_parse(json_stringify(_base));
    _singleton.level_dirs = []; _singleton.rooms = []; _singleton.room = "r_challengelevel";
    var _single_page = build_challenge_page(_singleton);
    _assert(array_length(_single_page.levels) == 1 && _single_page.levels[0].roomselect == r_challengelevel, "singleton room coverage");
    var _old_hardmode_unlock = global.hardmodeunlock;
    global.hardmodeunlock = 0;
    _assert(!levelselect_hardmode_available(), "hard mode locked before campaign completion");
    global.hardmodeunlock = 1;
    _assert(levelselect_hardmode_available(), "hard mode available after campaign completion");
    global.hardmodeunlock = _old_hardmode_unlock;
    var _old_world4 = global.world4;
    var _lunar_entry = levelselect_entry(r_challengelevel, -1, 1, 19, "Lunar Base Challenge/1");
    global.world4 = 0;
    _assert(!levelselect_unlocked(_lunar_entry), "Lunar world-four unlock is enforced");
    global.world4 = 1;
    _assert(levelselect_unlocked(_lunar_entry), "Lunar selectable after world-four unlock");
    global.world4 = _old_world4;
    var _old_run = global.challenge_run_id;
    var _old_select = global.levelselect;
    var _old_current = global.currentchallenge;
    var _old_challenges = global.challenges;
    var _old_cheats = global.cheats;
    var _old_workshop = global.workshop;
    global.challenge_run_id = -1; global.levelselect = 1;
    global.currentchallenge = 19; global.challenges = 1; global.cheats = 0; global.workshop = 0;
    _assert(!scr_challenge_run_eligible(19), "packaged practice ineligible");
    global.levelselect = 0;
    _assert(!scr_challenge_run_eligible(19), "practice remains ineligible after a flag reset");
    global.challenge_run_id = _old_run; global.levelselect = _old_select;
    global.currentchallenge = _old_current; global.challenges = _old_challenges;
    global.cheats = _old_cheats; global.workshop = _old_workshop;
    _assert(scr_campaign_save_selfcheck(), "campaign resume and practice isolation transactions");
    show_debug_message("TCC_LEVEL_SELECT_SELF_CHECK_PASS pages=" + string(array_length(_pages)) + " campaign=100 lunar=1");
    return true;
}
