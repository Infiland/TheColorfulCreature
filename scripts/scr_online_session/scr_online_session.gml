// =============================================================================
// ONLINE SESSIONS - what each player is doing, and how followers join it.
//
// A "session" is one continuous stretch of gameplay entered from a menu: a
// campaign run, an Endless Run, a challenge, a Workshop level, a shared level
// and so on. Its id (sid) changes whenever a player enters gameplay from a menu.
// The lobby owner publishes a descriptor of their session in lobby data. Members
// who joined that owner (followers) are taken into each new session the owner
// starts. Inside a session everyone progresses independently; Endless Runs share
// their level picks so the whole party plays the same sequence.
// =============================================================================

#macro NET_ROOM_MENU		0	// hub/menu/result rooms: no session, not joinable
#macro NET_ROOM_PLAY		1	// gameplay: joinable
#macro NET_ROOM_TRANSIT		2	// gameplay between levels (merchant, story): not joinable
#macro NET_ROOM_EDITOR		3	// level editor: joinable only while play-testing
#macro NET_ROOM_LOCAL		4	// local multiplayer: never joinable or interrupted

#macro NET_FOLLOW_COUNTDOWN	180	// ticks of warning before a follower is moved
#macro NET_FOLLOW_TIMEOUT_MS	90000

function net_session_init() {
    global.net_session_sid = "";
    global.net_session_adopt = "";
    global.net_session_in_menu = true;
    global.net_sid_counter = 0;
    global.net_level_key = "";
    global.net_shared_md5 = "";
    global.net_editor_md5 = "";
    global.net_challenge_md5 = "";
    global.net_challenge_share_path = "";
    global.net_publish_tick = 0;
    global.net_published_json = "";
    global.net_host_desc = undefined;
    global.net_host_desc_json = "";
    global.net_host_sid_seen = "";
    global.net_follow_poll_tick = 0;
    global.net_follow_quiet_until = 0;
    global.net_follow_waiting_notice = false;
    global.net_follow_job = undefined;
    global.net_er_index = 0;
    global.net_er_picks = ds_map_create();
    global.net_ugc_subscribed = [];
}

function net_session_cleanup() {
    net_ugc_release("");
    if (ds_exists(global.net_er_picks, ds_type_map)) ds_map_destroy(global.net_er_picks);
}

// Lobby left or lost: forget the old host, keep our own session.
function net_session_lobby_reset() {
    global.net_host_desc = undefined;
    global.net_host_desc_json = "";
    global.net_host_sid_seen = "";
    global.net_published_json = "";
    global.net_follow_job = undefined;
    global.net_follow_waiting_notice = false;
}

function net_field(_struct, _key, _default) {
    if (is_struct(_struct) && variable_struct_exists(_struct, _key)) return variable_struct_get(_struct, _key);
    return _default;
}
function net_number(_value, _default) {
    return net_finite(_value) ? _value : _default;
}
/// Steam ids travel as decimal strings: JSON doubles cannot hold 64-bit ids.
function net_parse_id(_text) {
    if (is_numeric(_text)) return int64(_text);
    if (!is_string(_text) || _text == "" || string_length(_text) > 20 || string_digits(_text) != _text) return int64(0);
    var _id = int64(0);
    try { _id = int64(_text); } catch (_error) { _id = int64(0); }
    return _id;
}
function net_new_sid() {
    global.net_sid_counter += 1;
    return string(global.net_my_steam_id) + "-" + string(global.net_sid_counter) + "-" + string(current_time mod 1000000);
}

/// @function net_room_class(room)
function net_room_class(_room) {
    if (!room_exists(_room)) return NET_ROOM_MENU;
    if (_room == r_leveleditor || _room == r_oldleveleditor) return NET_ROOM_EDITOR;
    var _name = room_get_name(_room);
    if (_room == r_localmultiplayermenu || string_pos("r_MUrace", _name) == 1 || string_pos("r_MUSurvival", _name) == 1) return NET_ROOM_LOCAL;
    static _menus = {
        r_mainmenu:true, r_loading:true, r_logointro:true, r_gamemode:true, r_funmodemenu:true, r_settings:true,
        r_achievements:true, r_stats:true, r_credits:true, r_support:true, r_levelselectmenu:true,
        r_endlessrunmenu:true, r_customlevelmenu:true, r_soundtestmenu:true, r_hardmodediff:true,
        r_onlineleaderboard:true, r_skinmenu:true, r_challenges:true, r_calendar:true,
        r_workshopchallengemenu:true, r_commentary:true, r_iapjoke:true, r_demofinishedscreen:true,
        r_gameoverscreen:true, r_hardmodedeathroom:true, r_dailylevelwin:true, r_workshoplevelwin:true,
        r_theend:true, r_fakeending:true, r_gameplay_qa:true, r_gameplay_qa_exit:true, r_testroom:true,
        r_templatelevelroom:true, r_redblocklayerroom:true
    };
    static _transit = {
        r_hatmerchantroom:true, r_tale:true, r_taleroom:true,
        r_boss1prepare:true, r_boss2prepare:true, r_boss3prepare:true, r_boss4prepare:true
    };
    if (variable_struct_exists(_menus, _name)) return NET_ROOM_MENU;
    // Challenge result rooms (r_kaizowin, r_lunarbasewin, ...) end their session.
    var _length = string_length(_name);
    if (_length > 3 && string_copy(_name, _length - 2, 3) == "win") return NET_ROOM_MENU;
    if (variable_struct_exists(_transit, _name)) return NET_ROOM_TRANSIT;
    return NET_ROOM_PLAY;
}

function net_challenge_def_current() {
    if (!variable_global_exists("currentchallenge")) return undefined;
    return scr_challenge_get_def(global.currentchallenge);
}

/// Identity of the level content currently played; "" when there is none.
function net_level_key_compute() {
    var _class = net_room_class(room);
    if (_class == NET_ROOM_MENU || _class == NET_ROOM_LOCAL) return "";
    if (_class == NET_ROOM_EDITOR) {
        if (room == r_leveleditor && global.LEMode == 2 && global.net_editor_md5 != "") return "lv:" + global.net_editor_md5;
        return "";
    }
    if (room == r_customlevelworkshop) {
        if (global.net_shared_md5 != "") return "lv:" + global.net_shared_md5;
        var _publish = variable_global_exists("Publish_ID") ? int64(net_number(global.Publish_ID, 0)) : int64(0);
        return _publish != 0 ? "ws:" + string(_publish) : "";
    }
    if (room == r_challengelevel) {
        var _def = net_challenge_def_current();
        if (is_undefined(_def)) return "";
        if (_def.is_custom) return global.net_challenge_md5 != "" ? "lv:" + global.net_challenge_md5 : "";
        return "ch:" + string(_def.id) + ":" + string(global.challenge_level_dir);
    }
    return room_get_name(room);
}

/// Runs every tick (online or not) before networking: tracks our own session.
function net_session_update() {
    if (!variable_global_exists("net_ready") || !global.net_ready) return;
    var _class = net_room_class(room);
    if (_class == NET_ROOM_MENU) {
        global.net_session_in_menu = true;
        global.net_shared_md5 = "";
        global.net_challenge_share_path = "";
        global.net_challenge_md5 = "";
    } else if (global.net_session_in_menu) {
        // Gameplay entered from a menu starts a new session, unless we are
        // following a host into theirs.
        global.net_session_in_menu = false;
        var _previous = global.net_session_sid;
        global.net_session_sid = global.net_session_adopt != "" ? global.net_session_adopt : net_new_sid();
        global.net_session_adopt = "";
        if (_previous != global.net_session_sid) net_ugc_release(global.net_session_sid);
    }
    if (_class != NET_ROOM_EDITOR) global.net_editor_md5 = "";
    if (net_enabled()) net_challenge_share_update();
    var _key = net_level_key_compute();
    if (_key != global.net_level_key) {
        global.net_level_key = _key;
        // Tell the party where we are right away instead of at the next keepalive.
        global.net_ping_at = 0;
        global.net_send_signature = "";
    }
}

// Custom challenge folders exist only on this machine: offer the current level.
function net_challenge_share_update() {
    if (room != r_challengelevel || !variable_global_exists("challenges") || global.challenges != 1) return;
    var _def = net_challenge_def_current();
    if (is_undefined(_def) || !_def.is_custom) return;
    var _base = (variable_global_exists("challenge_base_dir") && global.challenge_base_dir != "") ? global.challenge_base_dir : scr_challenge_get_base_dir();
    var _path = level_directory(_base) + string(global.challenge_level_dir);
    if (_path == global.net_challenge_share_path) return;
    global.net_challenge_share_path = _path;
    var _document = level_read(_path);
    global.net_challenge_md5 = is_undefined(_document) ? "" : net_levelshare_offer(json_stringify(_document));
}

/// PLAYMODELE hook: a play-test of the editor level becomes a joinable session.
function net_editor_playmode(_playing) {
    global.net_editor_md5 = "";
    if (!_playing || !variable_global_exists("net_ready") || !global.net_ready || !net_enabled()) return;
    try {
        var _document = level_capture();
        if (level_validate(_document).valid) global.net_editor_md5 = net_levelshare_offer(json_stringify(_document));
    } catch (_error) {
        global.net_editor_md5 = "";
        show_debug_message("[NET] Could not share the editor level: " + string(_error));
    }
    // Each play-test is a fresh session, so followers come along to the new version.
    if (global.net_editor_md5 != "") global.net_session_sid = net_new_sid();
}

/// o_player door hook. Shared levels have no rewards or next level: replay them.
function net_door_override() {
    if (!variable_global_exists("net_ready") || !global.net_ready) return false;
    if (room != r_customlevelworkshop || global.net_shared_md5 == "") return false;
    if (variable_global_exists("workshopchallenge") && global.workshopchallenge == 1) return false;
    net_notice(loc("NET_SHARED_LEVEL_COMPLETE"));
    global.time = 0;
    global.deaths = 0;
    global.pickup = 0;
    scr_resetcheckpointdata();
    room_restart();
    return true;
}

// -----------------------------------------------------------------------------
// Descriptors
// -----------------------------------------------------------------------------
function net_cer_capture() {
    var _levels = "";
    for (var _i = 1; _i <= 26; ++_i) _levels += (variable_global_exists("CERL" + string(_i)) && variable_global_get("CERL" + string(_i)) != 0) ? "1" : "0";
    var _music = "";
    for (var _i = 1; _i <= 29; ++_i) _music += (variable_global_exists("CERM" + string(_i)) && variable_global_get("CERM" + string(_i)) != 0) ? "1" : "0";
    return {l:_levels, m:_music, lives:global.CERLives, mc:global.CERMusicChange, up:global.CER1upChange};
}
function net_cer_apply(_cer) {
    var _levels = string(net_field(_cer, "l", ""));
    var _music = string(net_field(_cer, "m", ""));
    if (string_length(_levels) != 26 || string_length(_music) != 29) return false;
    if (string_pos("1", _levels) == 0 || string_pos("1", _music) == 0) return false;
    for (var _i = 1; _i <= 26; ++_i) variable_global_set("CERL" + string(_i), string_char_at(_levels, _i) == "1" ? 1 : 0);
    for (var _i = 1; _i <= 29; ++_i) variable_global_set("CERM" + string(_i), string_char_at(_music, _i) == "1" ? 1 : 0);
    global.CERLives = clamp(round(net_number(net_field(_cer, "lives", 5), 5)), 1, 9999);
    global.CERMusicChange = clamp(round(net_number(net_field(_cer, "mc", 10), 10)), 1, 1000);
    global.CER1upChange = clamp(round(net_number(net_field(_cer, "up", 10), 10)), 1, 1000);
    return true;
}

/// Describe what this player is doing, for followers and the Friends panel.
function net_session_capture() {
    var _class = net_room_class(room);
    var _desc = {v:NET_PROTOCOL, sid:global.net_session_sid, mode:"menu", joinable:false,
        room:room_get_name(room), key:global.net_level_key, title:""};
    if (_class == NET_ROOM_MENU) { _desc.sid = ""; return _desc; }
    if (_class == NET_ROOM_LOCAL) { _desc.mode = "local"; return _desc; }
    if (_class == NET_ROOM_EDITOR) {
        _desc.mode = "editor";
        if (global.net_level_key != "") {
            _desc.mode = "shared";
            _desc.md5 = global.net_editor_md5;
            _desc.title = net_clean_name(variable_global_exists("levelname") ? global.levelname : "");
            _desc.joinable = true;
        }
        return _desc;
    }
    _desc.joinable = (_class == NET_ROOM_PLAY);
    if (global.endless == 1) {
        _desc.mode = "endless";
        _desc.erm = global.endlessrunmode;
        _desc.eri = global.net_er_index;
        if (global.endlessrunmode == 1) _desc.diff = global.difficultyER;
        if (global.endlessrunmode == 3) _desc.cer = net_cer_capture();
        if (global.endlessrunmode == 4) {
            _desc.ws = string(int64(net_number(global.workshopER_current_file_id, 0)));
            if (room != r_customlevelworkshop) _desc.joinable = false;
        }
    } else if (variable_global_exists("workshopchallenge") && global.workshopchallenge == 1) {
        _desc.mode = "wschallenge";
        _desc.title = net_clean_name(global.workshopchallenge_title);
        _desc.index = global.workshopchallenge_index;
        _desc.dt = global.workshopchallenge_diamond_time;
        _desc.diff = global.workshopchallenge_difficulty;
        _desc.levels = [];
        var _levels = global.workshopchallenge_levels;
        for (var _i = 0; _i < min(64, array_length(_levels)); ++_i) {
            var _level = _levels[_i];
            var _id = is_struct(_level) ? net_field(_level, "id", 0) : _level;
            array_push(_desc.levels, {id:string(int64(net_number(_id, 0))), title:net_clean_name(is_struct(_level) ? net_field(_level, "title", "") : "")});
        }
        if (array_length(_levels) > 64) _desc.joinable = false;
    } else if (global.workshop == 1 && room == r_customlevelworkshop) {
        if (global.net_shared_md5 != "") {
            _desc.mode = "shared";
            _desc.md5 = global.net_shared_md5;
        } else {
            _desc.mode = "workshop";
            _desc.ws = string(int64(net_number(global.Publish_ID, 0)));
        }
        _desc.title = net_clean_name(variable_global_exists("levelname") ? global.levelname : "");
    } else if (global.challenges == 1) {
        var _def = net_challenge_def_current();
        if (is_undefined(_def)) {
            _desc.mode = "room";
        } else if (_def.is_custom) {
            if (room == r_challengelevel) {
                _desc.mode = "shared";
                _desc.md5 = global.net_challenge_md5;
                _desc.title = net_clean_name(scr_challenge_get_title(_def));
            } else _desc.mode = "room";
        } else {
            _desc.mode = "challenge";
            _desc.ch = _def.id;
            _desc.chl = global.challenge_level_index;
            _desc.chr = global.challenge_room_index;
            _desc.dir = string(global.challenge_level_dir);
            _desc.title = net_clean_name(scr_challenge_get_title(_def));
        }
    } else {
        _desc.mode = "room";
    }
    if (_desc.mode == "room") _desc.hard = global.hardmode;
    if (_desc.key == "") _desc.joinable = false;
    return _desc;
}

function net_session_valid(_desc) {
    if (!is_struct(_desc) || net_field(_desc, "v", 0) != NET_PROTOCOL) return false;
    var _strings = ["sid", "mode", "room", "key"];
    for (var _i = 0; _i < array_length(_strings); ++_i) {
        var _value = net_field(_desc, _strings[_i], undefined);
        if (!is_string(_value) || string_byte_length(_value) > 127) return false;
    }
    var _joinable = net_field(_desc, "joinable", false);
    _desc.joinable = (is_numeric(_joinable) || is_bool(_joinable)) && _joinable == true;
    var _title = net_field(_desc, "title", "");
    _desc.title = is_string(_title) ? net_clean_name(_title) : "";
    var _name = net_field(_desc, "name", "");
    _desc.name = is_string(_name) ? net_clean_name(_name) : "";
    if (_desc.sid == "") _desc.joinable = false;
    return true;
}

/// Host: publish our descriptor whenever it changes.
function net_session_publish(_force) {
    if (!global.net_active || !global.net_is_host) return;
    if (!_force && timing_tick_id() < global.net_publish_tick) return;
    global.net_publish_tick = timing_tick_id() + 15;
    var _desc = net_session_capture();
    _desc.name = net_clean_name(tcc_steam_get_persona_name());
    var _json = json_stringify(_desc);
    if (!_force && _json == global.net_published_json) return;
    global.net_published_json = _json;
    net_lobby_set("session", _json);
    net_lobby_set("current_room", _desc.room);
}

/// Client: the lobby owner's current descriptor (cached), or undefined.
function net_session_host_desc() {
    if (!global.net_active) return undefined;
    var _json = tcc_steam_lobby_get_data("session");
    if (!is_string(_json) || _json == "") return undefined;
    if (_json == global.net_host_desc_json) return global.net_host_desc;
    global.net_host_desc_json = _json;
    global.net_host_desc = undefined;
    if (string_byte_length(_json) > 8192) return undefined;
    var _desc = undefined;
    try { _desc = json_parse(_json); } catch (_error) { _desc = undefined; }
    if (net_session_valid(_desc)) global.net_host_desc = _desc;
    return global.net_host_desc;
}

// -----------------------------------------------------------------------------
// Following
// -----------------------------------------------------------------------------
function net_session_joined_lobby() {
    global.net_host_sid_seen = "*";	// never a real sid: the first descriptor counts
    global.net_follow_poll_tick = 0;
    global.net_follow_quiet_until = 0;
    global.net_follow_waiting_notice = true;
    global.net_follow_job = undefined;
}

// Ownership moved to another member: adopt their session as already seen so a
// migration never teleports anyone. Their next new session is followed as usual.
function net_session_owner_changed() {
    global.net_follow_quiet_until = current_time + 4000;
    global.net_follow_job = undefined;
}

function net_follow_poll() {
    if (!global.net_active || global.net_is_host) return;
    net_follow_job_tick();
    if (timing_tick_id() < global.net_follow_poll_tick) return;
    global.net_follow_poll_tick = timing_tick_id() + 15;
    var _desc = net_session_host_desc();
    if (is_undefined(_desc) || _desc.sid == global.net_host_sid_seen) return;
    var _first = global.net_follow_waiting_notice;
    global.net_host_sid_seen = _desc.sid;
    if (!global.net_follow_host || current_time < global.net_follow_quiet_until) return;
    if (!_desc.joinable) {
        if (_first) {
            global.net_follow_waiting_notice = false;
            net_notice(string_replace(loc("NET_WAITING_FOR_HOST"), "{NAME}", _desc.name));
        }
        return;
    }
    global.net_follow_waiting_notice = false;
    if (_desc.sid == global.net_session_sid && !_first) return;
    net_follow_start(_desc, false);
}

/// Go to wherever the host is right now (Friends panel, re-join).
function net_follow_now() {
    if (!global.net_active || global.net_is_host) return false;
    var _desc = net_session_host_desc();
    if (is_undefined(_desc) || !_desc.joinable) {
        net_notice(loc("NET_HOST_NOT_PLAYING"));
        return false;
    }
    global.net_host_sid_seen = _desc.sid;
    net_follow_start(_desc, true);
    return true;
}

function net_follow_start(_desc, _immediate) {
    var _wait = (_immediate || net_room_class(room) != NET_ROOM_PLAY) ? 0 : NET_FOLLOW_COUNTDOWN;
    global.net_follow_job = {sid:_desc.sid, desc:_desc, state:"countdown", timer:_wait, deadline:0,
        own_sid:global.net_session_sid};
}

function net_follow_cancel() {
    global.net_follow_job = undefined;
}

/// A follower is only moved where nothing can be lost or corrupted.
function net_follow_can_enter() {
    if (variable_global_exists("pause") && global.pause != 0) return false;
    if (instance_exists(o_settingspausemenu) || instance_exists(o_leveleditorleaveask)) return false;
    if (room == r_loading || room == r_logointro) return false;
    var _class = net_room_class(room);
    return _class != NET_ROOM_EDITOR && _class != NET_ROOM_LOCAL;
}

function net_follow_job_tick() {
    var _job = global.net_follow_job;
    if (!is_struct(_job)) return;
    if (!global.net_active || global.net_is_host || !global.net_follow_host) { net_follow_cancel(); return; }
    // The player started something else on their own while we waited.
    if (global.net_session_sid != _job.own_sid) {
        net_follow_cancel();
        return;
    }
    if (!net_follow_can_enter()) return;
    if (_job.timer > 0) { _job.timer -= 1; return; }
    // The host may have moved on within the same session: enter where they are now.
    var _latest = net_session_host_desc();
    if (is_struct(_latest) && _latest.sid == _job.sid) {
        if (!_latest.joinable) return;
        _job.desc = _latest;
    }
    var _result = "fail";
    try { _result = net_session_enter(_job.desc); }
    catch (_error) {
        _result = "fail";
        show_debug_message("[NET] Joining the host's session failed: " + string(_error));
    }
    if (_result == "wait") {
        if (_job.deadline == 0) _job.deadline = current_time + NET_FOLLOW_TIMEOUT_MS;
        _job.state = "wait";
        _job.timer = 30;
        if (current_time > _job.deadline) {
            net_follow_cancel();
            net_flash(false, loc("NET_FOLLOW_TIMEOUT"));
        }
        return;
    }
    net_follow_cancel();
    if (_result != "done") net_flash(false, loc("NET_FOLLOW_FAILED"));
}

// -----------------------------------------------------------------------------
// Entering a host's session
// -----------------------------------------------------------------------------
function net_session_enter(_desc) {
    if (platform_steam() && tcc_steam_get_app_id() == 1749610) return "fail";	// demo build
    switch (_desc.mode) {
        case "room": return net_enter_room(_desc);
        case "challenge": return net_enter_challenge(_desc);
        case "endless": return net_enter_endless(_desc);
        case "workshop": return net_enter_workshop(_desc);
        case "wschallenge": return net_enter_wschallenge(_desc);
        case "shared": return net_enter_shared(_desc);
    }
    return "fail";
}

/// Leave whatever this player was doing, as quitting to the menu would.
function net_enter_begin() {
    if (variable_global_exists("endless") && global.endless == 1 && global.endlessrunmode == 4) workshopER_cleanup();
    if (instance_exists(o_workshopERloading)) instance_destroy(o_workshopERloading);
    if (instance_exists(o_popup)) instance_destroy(o_popup);
    hidehud();
    level_music_release();
    audio_stop_all();
    scr_campaign_reset_context();
    global.endlessrunmode = 0;
    global.endlesslevel = 0;
    global.hardmodedifficulty = 0;
    global.time = 0;
    global.deaths = 0;
    global.pickup = 0;
    global.LEMode = 0;
    global.boss2health = 6;
    global.net_shared_md5 = "";
    window_set_cursor(cr_default);
}

/// Adopt the host's session id for the gameplay we are about to enter.
function net_enter_adopt(_desc) {
    global.net_session_adopt = global.net_session_in_menu ? _desc.sid : "";
    net_ugc_release(_desc.sid);
    global.net_session_sid = _desc.sid;
    global.net_host_sid_seen = _desc.sid;
}

function net_room_music(_room) {
    var _pages = get_levelselect_pages();
    for (var _p = 0; _p < array_length(_pages); ++_p) {
        var _levels = _pages[_p].levels;
        for (var _i = 0; _i < array_length(_levels); ++_i) {
            if (_levels[_i].roomselect != _room) continue;
            if (_levels[_i].levelmusic != -1) audio_play_sound(_levels[_i].levelmusic, 0, 1);
            return;
        }
    }
    // Boss rooms start their own music.
    if (string_pos("boss", room_get_name(_room)) > 0) return;
    global.chooserandommusic = irandom_range(1, 24);
    randomsong();
}

/// Campaign, level select, hard mode, daily, calendar and room-based custom
/// challenges: practice play of the host's room (no saves or full-run rewards).
function net_enter_room(_desc) {
    var _room = net_room_asset(_desc.room);
    if (_room == -1 || net_room_class(_room) != NET_ROOM_PLAY || _room == r_customlevelworkshop
        || _room == r_challengelevel) return "fail";
    net_enter_begin();
    global.levelselect = 1;
    global.challenge_run_id = -1;
    global.currentchallenge = -1;
    global.hatmerchantdiscount = 1.3333333333333;
    scr_resetcheckpointdata();
    net_room_music(_room);
    loadhud();
    net_enter_adopt(_desc);
    room_goto(_room);
    return "done";
}

/// Built-in challenges: practice of the same challenge level.
function net_enter_challenge(_desc) {
    var _def = scr_challenge_get_def(net_number(net_field(_desc, "ch", -1), -1));
    if (is_undefined(_def) || _def.is_custom) return net_enter_room(_desc);
    var _target = -1;
    var _dir = "";
    var _index = clamp(round(net_number(net_field(_desc, "chl", 0), 0)), 0, 10000);
    if (_desc.room == "r_challengelevel") {
        // Only the definition's own folders can be loaded, never a peer-chosen path.
        _dir = string(net_field(_desc, "dir", ""));
        var _known = (_dir == _def.level_dir);
        for (var _i = 0; _i < array_length(_def.level_dirs); ++_i) if (_def.level_dirs[_i] == _dir) { _known = true; _index = _i; }
        if (!_known || _dir == "") return "fail";
        var _base = (variable_global_exists("challenge_base_dir") && global.challenge_base_dir != "") ? global.challenge_base_dir : scr_challenge_get_base_dir();
        if (!level_exists(level_directory(_base) + _dir)) return "fail";
        _target = r_challengelevel;
    } else {
        _target = net_room_asset(_desc.room);
        if (_target == -1 || net_room_class(_target) != NET_ROOM_PLAY) return "fail";
    }
    net_enter_begin();
    global.levelselect = 1;
    global.challenge_run_id = -1;
    global.challenges = 1;
    global.currentchallenge = _def.id;
    global.DiamondMedalTimeChallenge = _def.diamond_time;
    global.challenge_custom = false;
    global.challenge_level_dir = "";
    global.challenge_level_index = 0;
    global.challenge_room_index = clamp(round(net_number(net_field(_desc, "chr", 0), 0)), 0, 10000);
    scr_resetcheckpointdata();
    if (_target == r_challengelevel) {
        if (!scr_challenge_prepare_custom_level(_def, _dir)) { level_load_failure(); return "fail"; }
        global.challenge_level_index = _index;
    }
    scr_challenge_play_music(_def);
    loadhud();
    net_enter_adopt(_desc);
    room_goto(_target);
    return "done";
}

/// Endless Runs: a fresh run of our own (own lives and level count) that
/// starts on the host's current level and shares the party's level picks.
function net_enter_endless(_desc) {
    var _mode = round(net_number(net_field(_desc, "erm", 0), 0));
    var _index = clamp(round(net_number(net_field(_desc, "eri", 1), 1)), 1, 1000000);
    if (_mode == 4) return net_enter_endless_workshop(_desc, _index);
    if (_mode < 1 || _mode > 3) return "fail";
    var _room = net_room_asset(_desc.room);
    if (_room == -1 || net_room_class(_room) != NET_ROOM_PLAY || _room == r_customlevelworkshop) return "fail";
    if (_mode == 3 && !net_cer_apply(net_field(_desc, "cer", undefined))) return "fail";
    net_enter_begin();
    global.endlessrunmode = _mode;
    global.endless = 1;
    global.special = 0;
    global.chooserandomlevel = 0;
    global.chosenlevelER = _room;
    if (_mode == 3) {
        global.hardmodelives = global.CERLives;
        global.endlessmusicchange = global.CERMusicChange;
        global.endless1upchange = global.CER1upChange;
        if (CERrandommusic()) randomsong();
    } else {
        global.hardmodelives = 5;
        global.endlessmusicchange = 10;
        global.endless1upchange = 10;
        global.chooserandommusic = irandom_range(1, 24);
        randomsong();
    }
    if (_mode == 1) {
        global.difficultyER = clamp(round(net_number(net_field(_desc, "diff", 1), 1)), 1, 10);
        global.difficultyincreaseER = irandom_range(4, 7);
    }
    instance_create(0, 0, o_levelcounter);
    loadhud();
    if (_mode == 1) instance_create(0, 0, o_difficultycounter);
    net_er_reset_picks();
    global.net_er_index = _index;
    global.net_er_picks[? string(_index)] = _desc.room;
    net_enter_adopt(_desc);
    room_goto(_room);
    return "done";
}

function net_enter_endless_workshop(_desc, _index) {
    if (!global.steam_api) return "fail";
    var _file = net_parse_id(net_field(_desc, "ws", ""));
    if (_file == 0) return "fail";
    if (net_ugc_folder(_file) == "") return net_ugc_request(_file, _desc.sid) ? "wait" : "fail";
    net_enter_begin();
    global.endlessrunmode = 4;
    global.endless = 1;
    global.workshop = 1;
    global.hardmodelives = 10;
    global.endlessmusicchange = 0;
    global.endless1upchange = 10;
    instance_create(0, 0, o_levelcounter);
    loadhud();
    workshopER_build_pool();
    // An item we downloaded only to follow the host is released with the run.
    for (var _i = array_length(global.net_ugc_subscribed) - 1; _i >= 0; --_i) {
        if (global.net_ugc_subscribed[_i].file == _file) {
            if (global.net_ugc_subscribed[_i].owned) array_push(global.workshopER_auto_subscribed, _file);
            array_delete(global.net_ugc_subscribed, _i, 1);
        }
    }
    if (!instance_exists(o_workshopERloading)) instance_create(0, 0, o_workshopERloading);
    global.workshopER_catalog_scan_done = false;
    global.workshopER_catalog_ids = [];
    global.workshopER_query_page = 1;
    workshopER_query_catalog();
    net_er_reset_picks();
    global.net_er_index = _index;
    global.net_er_picks[? string(_index)] = "ws:" + string(_file);
    global.workshopER_current_file_id = _file;
    global.workshopER_last_file_id = _file;
    net_enter_adopt(_desc);
    workshopER_goto_level(_file);
    return "done";
}

/// Standalone Workshop level: download it if needed, then play it normally.
function net_enter_workshop(_desc) {
    if (!global.steam_api) return "fail";
    var _file = net_parse_id(net_field(_desc, "ws", ""));
    if (_file == 0) return "fail";
    var _folder = net_ugc_folder(_file);
    if (_folder == "") return net_ugc_request(_file, _desc.sid) ? "wait" : "fail";
    var _directory = string_replace_all(directory_set(_folder, 1), "\\", "/");
    if (is_undefined(level_read(_directory))) return "fail";
    net_enter_begin();
    global.Publish_ID = _file;
    global.levelname = _desc.title;
    global.workshopfolder = _folder;
    if (!level_prepare_room(_directory, r_customlevelworkshop, true)) { level_load_failure(); return "fail"; }
    loadhud();
    instance_destroy(o_coincounter);
    if (!instance_exists(o_narrator)) instance_create(0, 0, o_narrator);
    net_enter_adopt(_desc);
    room_goto(r_customlevelworkshop);
    return "done";
}

/// Workshop challenge: download every level, then continue at the host's level.
function net_enter_wschallenge(_desc) {
    if (!global.steam_api) return "fail";
    var _source = net_field(_desc, "levels", []);
    if (!is_array(_source) || array_length(_source) == 0 || array_length(_source) > 64) return "fail";
    var _levels = [];
    var _waiting = false;
    for (var _i = 0; _i < array_length(_source); ++_i) {
        var _file = net_parse_id(net_field(_source[_i], "id", ""));
        if (_file == 0) return "fail";
        if (net_ugc_folder(_file) == "") {
            if (!net_ugc_request(_file, _desc.sid)) return "fail";
            _waiting = true;
        }
        var _title = net_field(_source[_i], "title", "");
        array_push(_levels, {id:_file, title:is_string(_title) ? net_clean_name(_title) : "Workshop Level", diamond_time:0, difficulty:0});
    }
    if (_waiting) return "wait";
    var _index = clamp(round(net_number(net_field(_desc, "index", 0), 0)), 0, array_length(_levels) - 1);
    net_enter_begin();
    global.challenges = 1;
    global.workshop = 1;
    global.workshopchallenge = 1;
    global.workshopchallenge_title = _desc.title != "" ? _desc.title : "Workshop Challenge";
    global.workshopchallenge_levels = _levels;
    global.workshopchallenge_index = _index;
    global.workshopchallenge_diamond_time = net_number(net_field(_desc, "dt", 0), 0);
    global.workshopchallenge_difficulty = net_number(net_field(_desc, "diff", 0), 0);
    global.workshopchallenge_signature = scr_workshopchallenge_signature(global.workshopchallenge_title, _levels);
    // Never marks a creator's draft as beaten on this machine.
    global.workshopchallenge_is_draft = 0;
    global.DiamondMedalTimeChallenge = global.workshopchallenge_diamond_time;
    scr_resetcheckpointdata();
    net_enter_adopt(_desc);
    scr_workshopchallenge_goto_level(_index);
    return "done";
}

/// Editor play-tests and custom challenge levels: receive the level, then play it.
function net_enter_shared(_desc) {
    var _md5 = string(net_field(_desc, "md5", ""));
    if (!net_levelshare_md5_valid(_md5)) return "fail";
    if (!net_levelshare_ready(_md5)) return net_levelshare_request(_md5, global.net_owner_id) ? "wait" : "fail";
    var _directory = net_levelshare_dir(_md5);
    if (is_undefined(level_read(_directory))) return "fail";
    net_enter_begin();
    global.Publish_ID = int64(0);
    global.levelname = _desc.title;
    global.workshopfolder = _directory;
    if (!level_prepare_room(_directory, r_customlevelworkshop, true)) { level_load_failure(); return "fail"; }
    global.net_shared_md5 = _md5;
    loadhud();
    instance_destroy(o_coincounter);
    if (!instance_exists(o_narrator)) instance_create(0, 0, o_narrator);
    net_enter_adopt(_desc);
    room_goto(r_customlevelworkshop);
    return "done";
}

// -----------------------------------------------------------------------------
// Workshop items needed to follow the host
// -----------------------------------------------------------------------------

/// Installed, fully downloaded folder of a Workshop level, or "".
function net_ugc_folder(_file) {
    var _info = ds_map_create();
    tcc_steam_ugc_get_item_update_info(_file, _info);
    var _ready = _info[? "is_installed"] == 1 && _info[? "is_downloading"] != 1 && _info[? "is_download_pending"] != 1;
    ds_map_destroy(_info);
    if (!_ready) return "";
    _info = ds_map_create();
    tcc_steam_ugc_get_item_install_info(_file, _info);
    var _folder = ds_map_exists(_info, "folder") ? string(_info[? "folder"]) : "";
    ds_map_destroy(_info);
    _folder = string_replace_all(_folder, "\\", "/");
    if (_folder == "") return "";
    if (string_copy(_folder, string_length(_folder), 1) != "/") _folder += "/";
    return level_exists(_folder) ? _folder : "";
}

/// Subscribe to an item a host's session needs (once per item). Items we
/// subscribed only for that session are released when we move on to another.
function net_ugc_request(_file, _sid) {
    if (!global.steam_api) return false;
    for (var _i = 0; _i < array_length(global.net_ugc_subscribed); ++_i) {
        if (global.net_ugc_subscribed[_i].file == _file) {
            global.net_ugc_subscribed[_i].sid = _sid;
            return true;
        }
    }
    var _subscribed = false;
    var _list = ds_list_create();
    tcc_steam_ugc_get_subscribed_items(_list);
    for (var _i = 0; _i < ds_list_size(_list); ++_i) if (_list[| _i] == _file) _subscribed = true;
    ds_list_destroy(_list);
    tcc_steam_ugc_subscribe_item(_file);
    array_push(global.net_ugc_subscribed, {file:_file, sid:_sid, owned:!_subscribed});
    return true;
}

/// Forget requests for other sessions, unsubscribing the items that were not
/// already subscribed by the player before.
function net_ugc_release(_keep_sid) {
    if (!variable_global_exists("net_ugc_subscribed")) return;
    for (var _i = array_length(global.net_ugc_subscribed) - 1; _i >= 0; --_i) {
        var _entry = global.net_ugc_subscribed[_i];
        if (_keep_sid != "" && _entry.sid == _keep_sid) continue;
        if (_entry.owned) tcc_steam_ugc_unsubscribe_item(_entry.file);
        array_delete(global.net_ugc_subscribed, _i, 1);
    }
}

// -----------------------------------------------------------------------------
// Endless Run level picks shared by everyone in the same run
// -----------------------------------------------------------------------------
function net_er_reset_picks() {
    ds_map_clear(global.net_er_picks);
    global.net_er_index = 0;
}

// Level numbers within the run; a run started from the Endless menu begins at 1.
function net_er_begin_pick() {
    if (!variable_global_exists("net_ready") || !global.net_ready) return 0;
    if (room == r_endlessrunmenu) net_er_reset_picks();
    global.net_er_index += 1;
    return global.net_er_index;
}

/// randomlevel() hook (modes 1-3): the first pick of each level number wins,
/// so everyone in the party plays the same sequence at their own pace.
function net_er_resolve_room(_room) {
    var _index = net_er_begin_pick();
    if (_index <= 0) return _room;
    var _known = global.net_er_picks[? string(_index)];
    if (is_string(_known)) {
        var _asset = net_room_asset(_known);
        if (_asset != -1 && net_room_class(_asset) == NET_ROOM_PLAY && _asset != r_customlevelworkshop) return _asset;
    }
    global.net_er_picks[? string(_index)] = room_get_name(_room);
    if (room != r_endlessrunmenu) net_er_send_picks(-1, _index, _index);
    return _room;
}

/// workshopERrandomlevel() hook (mode 4). Returns the party's pick or 0.
function net_er_resolve_workshop(_retry) {
    if (_retry) return int64(0);	// replacing a failed level keeps its number
    var _index = net_er_begin_pick();
    if (_index <= 0) return int64(0);
    var _known = global.net_er_picks[? string(_index)];
    if (is_string(_known) && string_pos("ws:", _known) == 1) return net_parse_id(string_delete(_known, 1, 3));
    return int64(0);
}
function net_er_record_workshop(_file, _broadcast) {
    if (!variable_global_exists("net_ready") || !global.net_ready || global.net_er_index <= 0) return;
    var _id = int64(net_number(_file, 0));
    if (_id == 0) return;
    global.net_er_picks[? string(global.net_er_index)] = "ws:" + string(_id);
    if (_broadcast && room != r_endlessrunmenu) net_er_send_picks(-1, global.net_er_index, global.net_er_index);
}
/// Go to a party-picked Workshop level, downloading it like a catalog pick.
function net_er_goto_workshop(_file) {
    global.workshopER_current_file_id = _file;
    global.workshopER_last_file_id = _file;
    if (net_ugc_folder(_file) != "") {
        workshopER_goto_level(_file);
        return;
    }
    var _owned = false;
    for (var _i = 0; _i < global.workshopER_pool_count; ++_i) if (global.workshopER_pool[_i].file_id == _file) _owned = true;
    for (var _i = 0; _i < array_length(global.workshopER_auto_subscribed); ++_i) if (global.workshopER_auto_subscribed[_i] == _file) _owned = true;
    tcc_steam_ugc_subscribe_item(_file);
    if (!_owned) array_push(global.workshopER_auto_subscribed, _file);
    global.workshopER_loading = true;
    if (!instance_exists(o_workshopERloading)) instance_create(0, 0, o_workshopERloading);
    with (o_workshopERloading) {
        target_file_id = _file;
        state = "waiting";
        wait_frames = 0;
        poll_timer = 0;
        dots = 0;
        dot_timer = 0;
    }
}

function net_er_send_picks(_target, _from, _to) {
    if (!variable_global_exists("net_ready") || !global.net_ready || !global.net_active || global.net_session_sid == "") return;
    if (array_length(global.net_member_list) == 0) return;
    var _buffer = global.net_send_buffer;
    buffer_seek(_buffer, buffer_seek_start, 0);
    buffer_write(_buffer, buffer_u8, NET_PACKET_ER_PICKS);
    buffer_write(_buffer, buffer_string, global.net_session_sid);
    var _count_at = buffer_tell(_buffer);
    buffer_write(_buffer, buffer_u8, 0);
    var _count = 0;
    for (var _i = max(1, _from); _i <= _to && _count < 24; ++_i) {
        var _key = global.net_er_picks[? string(_i)];
        if (!is_string(_key) || !net_key_valid(_key)) continue;
        if (buffer_tell(_buffer) + string_byte_length(_key) + 6 > NET_PACKET_MAX_SIZE) break;
        buffer_write(_buffer, buffer_u32, _i);
        buffer_write(_buffer, buffer_string, _key);
        _count += 1;
    }
    if (_count == 0) return;
    buffer_poke(_buffer, _count_at, buffer_u8, _count);
    var _size = buffer_tell(_buffer);
    if (_target == -1) net_broadcast(_size, true); else net_send_to(_target, _size, true);
}

function net_er_receive_picks(_buffer, _size) {
    if (_size < 4 || _size > NET_PACKET_MAX_SIZE) return;
    var _sid_end = net_packet_string_end(_buffer, 1, _size, 64);
    if (_sid_end < 0 || _sid_end + 1 >= _size) return;
    buffer_seek(_buffer, buffer_seek_start, 1);
    var _sid = buffer_read(_buffer, buffer_string);
    if (_sid == "" || _sid != global.net_session_sid || global.endless != 1) return;
    var _count = buffer_read(_buffer, buffer_u8);
    for (var _n = 0; _n < _count; ++_n) {
        if (buffer_tell(_buffer) + 5 > _size) return;
        var _index = buffer_read(_buffer, buffer_u32);
        if (net_packet_string_end(_buffer, buffer_tell(_buffer), _size, 127) < 0) return;
        var _key = buffer_read(_buffer, buffer_string);
        if (!net_key_valid(_key) || _index < 1 || _index > 1000000) continue;
        // The first pick of a level number wins; never rewrite one we know.
        if (!ds_map_exists(global.net_er_picks, string(_index))) global.net_er_picks[? string(_index)] = _key;
    }
}

/// A party member just entered our run: share the picks around and ahead of us.
function net_er_peer_joined_run(_peer, _sid) {
    if (_sid == "" || _sid != global.net_session_sid || !variable_global_exists("endless") || global.endless != 1) return;
    net_er_send_picks(_peer, global.net_er_index - 2, global.net_er_index + 30);
}

// -----------------------------------------------------------------------------
// Text for banners and the Friends panel
// -----------------------------------------------------------------------------
function net_session_text(_desc) {
    if (!is_struct(_desc)) return "";
    var _title = net_field(_desc, "title", "");
    switch (_desc.mode) {
        case "endless":
            switch (round(net_number(net_field(_desc, "erm", 1), 1))) {
                case 2: return loc("NET_MODE_OLD_ENDLESS");
                case 3: return loc("NET_MODE_CUSTOM_ENDLESS");
                case 4: return loc("NET_MODE_WORKSHOP_ENDLESS");
            }
            return loc("NET_MODE_ENDLESS");
        case "challenge": return string_replace(loc("NET_MODE_CHALLENGE"), "{NAME}", _title);
        case "workshop": return string_replace(loc("NET_MODE_WORKSHOP"), "{NAME}", _title);
        case "wschallenge": return string_replace(loc("NET_MODE_WORKSHOP_CHALLENGE"), "{NAME}", _title);
        case "shared": return string_replace(loc("NET_MODE_SHARED"), "{NAME}", _title);
        case "room":
            if (net_number(net_field(_desc, "hard", 0), 0) == 1) return loc("NET_MODE_HARD");
            return loc("NET_MODE_LEVEL");
        case "editor": return loc("NET_MODE_EDITOR");
        case "local": return loc("NET_MODE_LOCAL");
    }
    return loc("NET_MODE_MENU");
}
