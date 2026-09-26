function platform_services_save() {
    if (!variable_global_exists("service_owner")) return false;
    var _path = directory_set("/Save Files/") + "Services-" + md5_string_utf8(global.service_owner) + ".sav";
    scr_save_begin(_path);
    // INI strings cannot round-trip JSON's embedded quotation marks.
    ini_write_string("Services", "Achievements64", base64_encode(json_stringify(global.service_achievements)));
    ini_write_string("Services", "Scores64", base64_encode(json_stringify(global.service_scores)));
    return scr_save_finish(_path);
}

function platform_services_read_json(_path, _key, _encoded) {
    if (_encoded != "") return json_parse(base64_decode(_encoded));
    // Recover build 1's quoted JSON directly, before the INI parser truncates it.
    var _json = "{}";
    var _file = file_text_open_read(_path);
    if (_file >= 0) {
        var _prefix = _key + "=\"";
        while (!file_text_eof(_file)) {
            var _line = string_trim(file_text_read_string(_file));
            file_text_readln(_file);
            if (string_pos(_prefix, _line) == 1 && string_char_at(_line, string_length(_line)) == "\"")
                _json = string_copy(_line, string_length(_prefix) + 1, string_length(_line) - string_length(_prefix) - 1);
        }
        file_text_close(_file);
    }
    return json_parse(_json);
}

function platform_service_score_valid(_entry) {
    return is_struct(_entry) && variable_struct_exists(_entry, "score")
        && is_real(_entry.score) && !is_nan(_entry.score) && !is_infinity(_entry.score)
        && _entry.score >= 0 && _entry.score <= 2147483647
        && variable_struct_exists(_entry, "pending") && (_entry.pending == true || _entry.pending == false);
}

function platform_score_is_timed_board(_board) {
    return string_pos("Time", _board) > 0 || _board == "Endless Run 20L" || _board == "Endless Run 50L";
}

function platform_time_milliseconds_to_centiseconds(_milliseconds) {
	// GML's round() resolves exact half values downward. Use conventional
	// nearest-centisecond rounding instead of biasing half-centisecond times down.
	return floor(_milliseconds / 10 + 0.5);
}

function platform_services_load(_owner) {
    global.service_owner = _owner;
    global.service_achievements = {};
    global.service_scores = {};
    global.service_inflight = false;
    global.service_request = variable_global_exists("service_request") ? global.service_request + 1 : 0;
    global.service_inflight_at = 0;
    global.service_next_attempt = 0;
    var _path = directory_set("/Save Files/") + "Services-" + md5_string_utf8(_owner) + ".sav";
    scr_save_recover(_path);
    if (!file_exists(_path)) return;
    ini_open(_path);
    var _achievements = ini_read_string("Services", "Achievements64", "");
    var _scores = ini_read_string("Services", "Scores64", "");
    ini_close();
    var _scores_migrated = false;
    try {
        var _a = platform_services_read_json(_path, "Achievements", _achievements);
        var _s = platform_services_read_json(_path, "Scores", _scores);
        if (is_struct(_a)) {
            var _keys = variable_struct_get_names(_a);
            for (var _i = 0; _i < array_length(_keys); ++_i) {
                var _value = variable_struct_get(_a, _keys[_i]);
                if (platform_achievement_id(_keys[_i]) != "" && is_real(_value) && (_value == 0 || _value == 1))
                    variable_struct_set(global.service_achievements, _keys[_i], _value);
            }
        }
        if (is_struct(_s)) {
            var _keys = variable_struct_get_names(_s);
            for (var _i = 0; _i < array_length(_keys); ++_i) {
                var _entry = variable_struct_get(_s, _keys[_i]);
                if (!platform_service_score_valid(_entry)) continue;
                // Earlier Apple builds queued these records in milliseconds. Game Center's
                // hundredth-second format expects centiseconds, so migrate each old record once.
                if (platform_apple() && platform_score_is_timed_board(_keys[_i])
                    && !variable_struct_exists(_entry, "apple_time_centiseconds")) {
                    _entry.score = platform_time_milliseconds_to_centiseconds(_entry.score);
                    _entry.apple_time_centiseconds = true;
                    _scores_migrated = true;
                }
                variable_struct_set(global.service_scores, _keys[_i], _entry);
            }
        }
    } catch (_error) { show_debug_message("Invalid service progress: " + string(_error)); }
    if (_scores_migrated) platform_services_save();
}

function platform_services_account(_owner) {
    if (!is_string(_owner) || _owner == "") return;
    if (_owner != global.service_owner) {
        platform_services_save();
        var _first_account = global.service_owner == "";
        var _a = global.service_achievements;
        var _s = global.service_scores;
        platform_services_load(_owner);
        if (_first_account) {
            var _keys = variable_struct_get_names(_a);
            for (var _i = 0; _i < array_length(_keys); ++_i) {
                if (!variable_struct_exists(global.service_achievements, _keys[_i]))
                    variable_struct_set(global.service_achievements, _keys[_i], 0);
            }
            _keys = variable_struct_get_names(_s);
            for (var _i = 0; _i < array_length(_keys); ++_i) {
                if (!variable_struct_exists(global.service_scores, _keys[_i]))
                    variable_struct_set(global.service_scores, _keys[_i], variable_struct_get(_s, _keys[_i]));
            }
            // Consume anonymous progress once; it must not follow subsequent account changes.
            var _anonymous = directory_set("/Save Files/") + "Services-" + md5_string_utf8("") + ".sav";
            if (platform_services_save()) {
                scr_save_begin(_anonymous);
                ini_write_string("Services", "Achievements", "{}");
                ini_write_string("Services", "Scores", "{}");
                scr_save_finish(_anonymous);
            }
        }
        var _account_file = directory_set("/Save Files/") + "ServicesAccount.sav";
        scr_save_begin(_account_file);
        ini_write_string("Services", "Owner", _owner);
        scr_save_finish(_account_file);
        platform_services_save();
    }
    global.service_authenticated = true;
    global.service_next_attempt = 0;
}

function platform_google_auth_result(_result, _authenticated = false) {
    global.service_authenticated = false;
    if (!_result.success || !_authenticated) return;
    play_services_player_current_id(function(_result, _id = undefined) {
        if (_result.success && is_string(_id)) platform_services_account("google:" + _id);
    });
}

function platform_services_init() {
    if (variable_global_exists("service_owner")) return;
    global.service_authenticated = false;
    var _owner = "";
    var _path = directory_set("/Save Files/") + "ServicesAccount.sav";
    scr_save_recover(_path);
    if (file_exists(_path)) {
        ini_open(_path);
        _owner = ini_read_string("Services", "Owner", "");
        ini_close();
    }
    platform_services_load(_owner);
    if (platform_apple()) {
        gamecenter_local_player_authenticate(function(_result) {
            global.service_authenticated = false;
            if (_result.success && _result.authenticated && is_struct(_result.player))
                platform_services_account("apple:" + _result.player.game_player_id);
        });
    } else if (platform_google_play()) {
        play_services_is_authenticated(platform_google_auth_result);
    }
}

function achievement_earned(_id) {
    if (tcc_steam_initialised()) return steam_get_achievement(_id);
    if (!variable_global_exists("service_achievements")) return false;
    return variable_struct_exists(global.service_achievements, _id);
}

function achievement_award(_id) {
    if (variable_global_exists("cheats") && global.cheats != 0) return false;
    if (tcc_steam_initialised()) return steam_set_achievement(_id);
    if (platform_achievement_id(_id) == "" || !variable_global_exists("service_achievements")) return false;
    if (!variable_struct_exists(global.service_achievements, _id)) {
        variable_struct_set(global.service_achievements, _id, 0);
        platform_services_save();
    }
    return true;
}

function platform_submit_score(_board, _score) {
    return platform_submit_score_ext(_board, _score, false);
}

function platform_submit_score_ext(_board, _score, _force) {
    if (!is_real(_score) || is_nan(_score) || is_infinity(_score) || _score < 0 || global.cheats != 0) return false;
    // A challenge record can only originate from a complete eligible run.
    if (global.challenges == 1 && global.workshop == 0 && !scr_challenge_run_eligible(global.currentchallenge)) return false;
    if (tcc_steam_initialised()) return steam_upload_score_ext(_board, _score, _force);
    if (!platform_apple() || !variable_global_exists("service_scores")) return false;
    var _id = platform_apple_board(_board);
    if (_id == "") return false;
    _score = clamp(round(_score), 0, 2147483647);
    var _timed = platform_score_is_timed_board(_board);
    if (_timed) _score = platform_time_milliseconds_to_centiseconds(_score);
    var _lower = _timed;
    var _old = variable_struct_exists(global.service_scores, _board) ? variable_struct_get(global.service_scores, _board) : undefined;
    if (is_struct(_old) && !_force && (_lower ? _old.score <= _score : _old.score >= _score)) return true;
    var _entry = {score:_score, pending:true};
    if (_timed) _entry.apple_time_centiseconds = true;
    variable_struct_set(global.service_scores, _board, _entry);
    platform_services_save();
    return true;
}

function platform_services_flush() {
    if (!variable_global_exists("service_owner")) return;
    if (platform_apple() && !gamecenter_local_player_is_authenticated()) global.service_authenticated = false;
    if (global.service_inflight && current_time - global.service_inflight_at >= 30000) {
        global.service_inflight = false;
        global.service_request += 1;
        global.service_next_attempt = current_time + 60000;
    }
    if (!global.service_authenticated || global.service_inflight || current_time < global.service_next_attempt) return;
    var _keys = variable_struct_get_names(global.service_achievements);
    for (var _i = 0; _i < array_length(_keys); ++_i) {
        var _id = _keys[_i];
        if (variable_struct_get(global.service_achievements, _id) != 0) continue;
        var _provider_id = platform_achievement_id(_id);
        if (_provider_id == "") continue;
        global.service_inflight = true;
        global.service_inflight_at = current_time;
        global.service_request += 1;
        var _callback = method({owner:global.service_owner, request:global.service_request, achievement:_id}, function(_result) {
            if (owner != global.service_owner || request != global.service_request) return;
            global.service_inflight = false;
            global.service_next_attempt = current_time + (_result.success ? 250 : 60000);
            if (_result.success) {
                variable_struct_set(global.service_achievements, achievement, 1);
                platform_services_save();
            }
        });
        if (platform_apple()) gamecenter_achievement_report(_provider_id, 100, true, _callback);
        else if (platform_google_play()) play_services_achievements_unlock(_provider_id, _callback);
        return;
    }
    if (!platform_apple() && !platform_google_play()) return;
    _keys = variable_struct_get_names(global.service_scores);
    for (var _i = 0; _i < array_length(_keys); ++_i) {
        var _board = _keys[_i];
        var _entry = variable_struct_get(global.service_scores, _board);
        if (!platform_service_score_valid(_entry) || !_entry.pending) continue;
        var _provider_id = platform_apple() ? platform_apple_board(_board) : _board;
        if (_provider_id == "") continue;
        global.service_inflight = true;
        global.service_inflight_at = current_time;
        global.service_request += 1;
        var _callback = method({owner:global.service_owner, request:global.service_request, board:_board, score:_entry.score}, function(_result) {
                if (owner != global.service_owner || request != global.service_request) return;
                global.service_inflight = false;
                global.service_next_attempt = current_time + (_result.success ? 250 : 60000);
                var _entry = variable_struct_get(global.service_scores, board);
                if (_result.success && _entry.score == score) {
                    _entry.pending = false;
                    platform_services_save();
                }
            });
        if (platform_apple()) gamecenter_leaderboard_submit(_provider_id, _entry.score, 0, _callback);
        else play_services_leaderboard_submit_score(_provider_id, _entry.score, _callback);
        return;
    }
}

function platform_show_achievements() {
    if (platform_apple()) {
        platform_interrupt();
        gamecenter_access_point_present_with_state(GameCenterViewState.Achievements, function() {});
    } else if (platform_google_play()) {
        platform_interrupt();
        if (!global.service_authenticated) play_services_sign_in(platform_google_auth_result);
        else play_services_achievements_show();
    } else if (platform_steam()) room_goto(r_achievements);
}

function platform_show_leaderboards() {
    if (platform_apple()) {
        platform_interrupt();
        gamecenter_access_point_present_with_state(GameCenterViewState.Leaderboards, function() {});
    } else if (platform_google_play()) {
        platform_interrupt();
        if (!global.service_authenticated) play_services_sign_in(platform_google_auth_result);
        else play_services_leaderboard_show_all();
    } else if (platform_steam()) room_goto(r_onlineleaderboard);
}

function platform_google_score(_id, _score) {
    if (!platform_google_play() || !variable_global_exists("service_scores") || global.cheats) return;
    if (!is_string(_id) || _id == "" || !is_real(_score) || is_nan(_score) || is_infinity(_score) || _score < 0) return;
    if (global.challenges && !scr_challenge_run_eligible(global.currentchallenge)) return;
    _score = clamp(round(_score), 0, 2147483647);
    // Existing Android boards are challenge times (lower) or daily streak (higher).
    var _lower = _id != "CgkI36PRjvEQEAIQMQ";
    var _old = variable_struct_exists(global.service_scores, _id) ? variable_struct_get(global.service_scores, _id) : undefined;
    if (platform_service_score_valid(_old) && (_lower ? _old.score <= _score : _old.score >= _score)) return;
    variable_struct_set(global.service_scores, _id, {score:_score, pending:true});
    platform_services_save();
}

function platform_apple_board(_board) {
    switch (_board) {
    case "Big Room Challenge Time": return "com.infiland.tcc.board.big_room_challenge_time";
    case "Blind Challenge Time": return "com.infiland.tcc.board.blind_challenge_time";
    case "Breakable Challenge Time": return "com.infiland.tcc.board.breakable_challenge_time";
    case "Calendar Wins": return "com.infiland.tcc.board.calendar_wins";
    case "Cog Distance": return "com.infiland.tcc.board.cog_distance";
    case "Community Challenge Time": return "com.infiland.tcc.board.community_challenge_time";
    case "Corrupted Spike Challenge Time": return "com.infiland.tcc.board.corrupted_spike_challenge_time";
    case "DJ Challenge Time": return "com.infiland.tcc.board.dj_challenge_time";
    case "Daily Level Streak": return "com.infiland.tcc.board.daily_level_streak";
    case "Endless Run": return "com.infiland.tcc.board.endless_run";
    case "Endless Run 20L": return "com.infiland.tcc.board.endless_run_20l";
    case "Endless Run 50L": return "com.infiland.tcc.board.endless_run_50l";
    case "Invisible Challenge Time": return "com.infiland.tcc.board.invisible_challenge_time";
    case "Kaizo Challenge Time": return "com.infiland.tcc.board.kaizo_challenge_time";
    case "Ladder Challenge Time": return "com.infiland.tcc.board.ladder_challenge_time";
    case "Moving Challenge Time": return "com.infiland.tcc.board.moving_challenge_time";
    case "Old School Endless Run": return "com.infiland.tcc.board.old_school_endless_run";
    case "Slippery Challenge Time": return "com.infiland.tcc.board.slippery_challenge_time";
    case "Speed Challenge Time": return "com.infiland.tcc.board.speed_challenge_time";
    case "Spike Challenge Time": return "com.infiland.tcc.board.spike_challenge_time";
    case "Troop Challenge Time": return "com.infiland.tcc.board.troop_challenge_time";
    case "Tutorial Challenge Time": return "com.infiland.tcc.board.tutorial_challenge_time";
    case "Water Challenge Time": return "com.infiland.tcc.board.water_challenge_time";
    case "World 6 Challenge Time": return "com.infiland.tcc.board.world_6_challenge_time";
    case "World 7 Challenge Time": return "com.infiland.tcc.board.world_7_challenge_time";
    case "World 1 Time": return "com.infiland.tcc.board.world_1_time";
    case "World 2 Time": return "com.infiland.tcc.board.world_2_time";
    case "World 3 Time": return "com.infiland.tcc.board.world_3_time";
    case "World 4 Time": return "com.infiland.tcc.board.world_4_time";
    case "World 5 Time": return "com.infiland.tcc.board.world_5_time";
    }
    return "";
}
function platform_achievement_id(_id) {
    if (platform_apple()) {
        switch (_id) {
        case "ABSOLUTE_ENDLESS_HELL":
        case "A_FAN_OF_HATS":
        case "A_SMALL_LOAN":
        case "BENCHMARK":
        case "BIGROOM_CHALLENGE":
        case "BLIND_CHALLENGE":
        case "BOSS_KILL_1":
        case "BOSS_KILL_2":
        case "BOSS_KILL_3":
        case "BOSS_KILL_4":
        case "BREAKABLE_CHALLENGE":
        case "BRONZE_MEDAL":
        case "BYE_BYE_LEVEL":
        case "CALENDAR_EASY":
        case "CALENDAR_HARD":
        case "CALENDAR_MEDIUM":
        case "CHECKPOINT":
        case "CLICK_THE_HOTDOG":
        case "COIN_1":
        case "COIN_11":
        case "COIN_5":
        case "COMMUNITY_CHALLENGE":
        case "CORRUPTED_SPIKE_CHALLENGE":
        case "DAILIES":
        case "DEATHS_1":
        case "DEATHS_11":
        case "DEATHS_5":
        case "DIAMOND_LOVER":
        case "DIAMOND_MEDAL":
        case "DOUBLEJUMP_CHALLENGE":
        case "EASTEREGG_1":
        case "EASTEREGG_2":
        case "EASTEREGG_3":
        case "EASTEREGG_4":
        case "ENDLESS_BEGINNER":
        case "ENDLESS_EXPERT":
        case "ENDLESS_MASTER":
        case "ENDLESS_RUNNER":
        case "FIRST_CHALLENGE":
        case "FIRST_HAT":
        case "FLAG_GUY":
        case "GOLDEN_SPIKE_DEATH":
        case "GOLD_MEDAL":
        case "GRAYSCALE":
        case "HAT_COMPLETIONIST":
        case "HAT_MERCHANT":
        case "HM_DIFFICULT":
        case "HM_IMPOSSIBLE":
        case "HM_INSANE":
        case "HM_MEDIUM":
        case "HM_RIDICULOUS":
        case "HM_YEAHGL":
        case "INVISIBLE_CHALLENGE":
        case "INVISIBLE_SKIN":
        case "JACKPOT":
        case "JUMP_1":
        case "JUMP_11":
        case "JUMP_5":
        case "KAIZO_CHALLENGE":
        case "LADDER_CHALLENGE":
        case "LEVEL_COMPLETION_1":
        case "LEVEL_COMPLETION_11":
        case "LEVEL_COMPLETION_5":
        case "MONEY_SAVER":
        case "MOVING_CHALLENGE":
        case "OH_NO_THERES_MORE":
        case "PERFECT_CHALLENGE":
        case "POTATO_SETTINGS":
        case "SILVER_MEDAL":
        case "SKIN_COMPLETIONIST":
        case "SLIPPERY_CHALLENGE":
        case "SPEED_CHALLENGE":
        case "SPIKE_CHALLENGE":
        case "SPINNNNN":
        case "THE_ANTI_DEATH":
        case "THE_CROWN":
        case "THE_GLITTERING_RICH":
        case "THE_REVERSE_PROBLEM":
        case "TORCHERD":
        case "TROOP_CHALLENGE":
        case "TUTORIAL_CHALLENGE":
        case "UH_OH":
        case "WATER_CHALLENGE":
        case "WEIRD_SPIKE_DEATH":
        case "WORLD_1_QUICK":
        case "WORLD_2_QUICK":
        case "WORLD_3_QUICK":
        case "WORLD_4_QUICK":
        case "WORLD_5_QUICK":
        case "WORLD_6":
        case "WORLD_7":
        case "WORLD_WIDE_WEB":
        case "YOU_WIN":
            return "com.infiland.tcc.achievement." + string_lower(_id);
        }
    }
    if (platform_google_play()) {
        switch (_id) {
        case "LEVEL_COMPLETION_1": return "CgkI36PRjvEQEAIQAA";
        case "LEVEL_COMPLETION_2": return "CgkI36PRjvEQEAIQAw";
        case "LEVEL_COMPLETION_3": return "CgkI36PRjvEQEAIQBA";
        case "LEVEL_COMPLETION_4": return "CgkI36PRjvEQEAIQBQ";
        case "LEVEL_COMPLETION_5": return "CgkI36PRjvEQEAIQBg";
        case "LEVEL_COMPLETION_6": return "CgkI36PRjvEQEAIQBw";
        case "LEVEL_COMPLETION_7": return "CgkI36PRjvEQEAIQCA";
        case "LEVEL_COMPLETION_8": return "CgkI36PRjvEQEAIQCQ";
        case "LEVEL_COMPLETION_9": return "CgkI36PRjvEQEAIQCg";
        case "LEVEL_COMPLETION_10": return "CgkI36PRjvEQEAIQCw";
        case "LEVEL_COMPLETION_11": return "CgkI36PRjvEQEAIQDA";
        case "COIN_1": return "CgkI36PRjvEQEAIQDQ";
        case "COIN_2": return "CgkI36PRjvEQEAIQAw";
        case "COIN_3": return "CgkI36PRjvEQEAIQDw";
        case "COIN_4": return "CgkI36PRjvEQEAIQEA";
        case "COIN_5": return "CgkI36PRjvEQEAIQEQ";
        case "COIN_6": return "CgkI36PRjvEQEAIQEg";
        case "COIN_7": return "CgkI36PRjvEQEAIQEw";
        case "COIN_8": return "CgkI36PRjvEQEAIQFA";
        case "COIN_9": return "CgkI36PRjvEQEAIQFQ";
        case "COIN_10": return "CgkI36PRjvEQEAIQFg";
        case "COIN_11": return "CgkI36PRjvEQEAIQFw";
        case "DEATHS_1": return "CgkI36PRjvEQEAIQGA";
        case "DEATHS_2": return "CgkI36PRjvEQEAIQGQ";
        case "DEATHS_3": return "CgkI36PRjvEQEAIQGg";
        case "DEATHS_4": return "CgkI36PRjvEQEAIQGw";
        case "DEATHS_5": return "CgkI36PRjvEQEAIQHA";
        case "DEATHS_6": return "CgkI36PRjvEQEAIQHQ";
        case "DEATHS_7": return "CgkI36PRjvEQEAIQHg";
        case "DEATHS_8": return "CgkI36PRjvEQEAIQHw";
        case "DEATHS_9": return "CgkI36PRjvEQEAIQIA";
        case "DEATHS_10": return "CgkI36PRjvEQEAIQIQ";
        case "DEATHS_11": return "CgkI36PRjvEQEAIQIg";
        case "BOSS_KILL_1": return "CgkI36PRjvEQEAIQIw";
        case "BOSS_KILL_2": return "CgkI36PRjvEQEAIQJA";
        case "BOSS_KILL_3": return "CgkI36PRjvEQEAIQJQ";
        case "BOSS_KILL_4": return "CgkI36PRjvEQEAIQJg";
        case "YOU_WIN": return "CgkI36PRjvEQEAIQJw";
        }
    }
    return "";
}
