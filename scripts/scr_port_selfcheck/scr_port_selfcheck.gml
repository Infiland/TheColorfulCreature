function scr_port_assert(_condition, _message) {
    if (!_condition) throw "Port self-check failed: " + _message;
}

function scr_port_selfcheck() {
    platform_master_gain(0);
    scr_port_assert(mobile_confirmation_hit(336, 472) == ord("N"), "confirmation No hit target");
    scr_port_assert(mobile_confirmation_hit(688, 472) == ord("Y"), "confirmation Yes hit target");
    scr_port_assert(mobile_confirmation_hit(512, 472) == 0, "confirmation gap ignores taps");
    scr_port_assert(mobile_confirmation_hit(688, 550) == 0, "confirmation outside ignores taps");
    platform_touch_defaults();
    scr_port_assert(global.androidrightx - global.androidleftx >= 192, "movement button spacing");
    scr_port_assert(point_distance(global.androidjumpx, global.androidjumpy, global.androidinteractx, global.androidinteracty) > 190, "action button spacing");
    scr_port_assert(platform_touch_clamp(-100, 76, 948, 512) == 76, "touch left safe area");
    scr_port_assert(platform_touch_clamp(1200, 76, 948, 512) == 948, "touch right safe area");
    scr_port_assert(platform_touch_clamp(undefined, 76, 948, 512) == 512, "invalid touch position");
    scr_port_assert(platform_skip_progress(0.7) == 0 && abs(platform_skip_progress(0.35) - 0.5) < 0.001 && platform_skip_progress(-0.01) == 1, "skip progress fills over hold duration");
    scr_port_assert(scr_saved_room("r_lvl1") == r_lvl1, "legacy campaign room");
    scr_port_assert(scr_saved_room("r_lvl100") == r_lvl100, "final campaign room");
    scr_port_assert(scr_saved_room("missing_room") == -1, "missing room");
    scr_port_assert(scr_saved_room("o_player") == -1, "wrong resource type");
    scr_port_assert(scr_saved_room("r_leveleditor") == -1, "noncampaign room");
    global.cheats = 0; global.levelselect = 0; global.challenges = 1; global.workshop = 0;
    global.challenge_run_id = 7; global.currentchallenge = 7;
    scr_port_assert(scr_challenge_run_eligible(7), "full challenge");
    global.levelselect = 1; global.challenge_run_id = -1;
    scr_port_assert(!scr_challenge_run_eligible(7), "practice final level");
    global.levelselect = 0;
    scr_port_assert(!scr_challenge_run_eligible(7), "practice after returning from pause");
    global.challenge_run_id = 7; global.cheats = 1;
    scr_port_assert(!scr_challenge_run_eligible(7), "cheated challenge");
    var _session = {granted:false};
    scr_port_assert(ads_claim_reward(_session), "first reward");
    scr_port_assert(!ads_claim_reward(_session), "duplicate reward");
    scr_port_assert(!ads_claim_reward(undefined), "missing ad session");
    scr_port_assert(!ads_claim_reward({}), "malformed ad session");
    scr_port_assert(platform_service_score_valid({score:42, pending:true}), "queued score");
    scr_port_assert(!platform_service_score_valid({pending:true}), "missing queued score");
    scr_port_assert(!platform_service_score_valid({score:-1, pending:true}), "negative queued score");
    scr_port_assert(platform_score_is_timed_board("Big Room Challenge Time"), "challenge time board detection");
    scr_port_assert(platform_score_is_timed_board("Endless Run 20L"), "endless time board detection");
    scr_port_assert(!platform_score_is_timed_board("Endless Run"), "endless level board remains numeric");
    scr_port_assert(platform_time_milliseconds_to_centiseconds(12345) == 1235, "Game Center time score uses centiseconds");
    scr_port_assert(platform_time_milliseconds_to_centiseconds(12344) == 1234, "centisecond conversion preserves values below the half boundary");
    var _dir = game_save_id + "/PortSelfCheck/";
    directory_create(_dir);
    var _services = _dir + "Services.sav";
    ini_open(_services);
    ini_write_string("Services", "Scores", json_stringify({test:{score:42,pending:true}}));
    ini_write_string("Services", "Scores64", base64_encode(json_stringify({test:{score:84,pending:true}})));
    ini_close();
    ini_open(_services);
    var _encoded = ini_read_string("Services", "Scores64", "");
    ini_close();
    scr_port_assert(platform_services_read_json(_services, "Scores", "").test.score == 42, "legacy quoted service JSON recovery");
    scr_port_assert(platform_services_read_json(_services, "Scores", _encoded).test.score == 84, "encoded service JSON round trip");
    var _json_file = file_text_open_write(_dir + "test.json");
    file_text_write_string(_json_file, "{\"value\":42}");
    file_text_close(_json_file);
    var _json = LoadJSONFromFile(_dir + "test.json");
    scr_port_assert(!is_undefined(_json), "JSON file decoding");
    scr_port_assert(_json[? "value"] == 42, "JSON value");
    ds_map_destroy(_json);
    scr_port_assert(file_exists("challenges/challenges.json"), "bundled challenge manifest");
    scr_port_assert(tcc_gamepad_button_index(gp_shoulderlb) == 6, "left trigger mapping");
    scr_port_assert(tcc_gamepad_button_index(gp_padr) == 15, "dpad mapping");
    var _path = _dir + "Stats.sav";
    scr_save_begin(_path);
    ini_write_real("Test", "Progress", 12);
    scr_port_assert(scr_save_finish(_path), "initial save");
    scr_save_begin(_path);
    ini_write_real("Test", "Progress", 24);
    scr_port_assert(scr_save_finish(_path), "save replacement");
    ini_open(_path + ".bak");
    scr_port_assert(ini_read_real("Test", "Progress", 0) == 12, "previous progress backup");
    ini_close();
    file_delete(_path);
    scr_save_recover(_path);
    scr_port_assert(scr_files_equal(_path, _path + ".bak"), "interrupted save recovery");
    var _target = _dir + "Migrated/";
    scr_migrate_saves(_target, _dir);
    scr_port_assert(scr_files_equal(_path, _target + "Stats.sav"), "migration copy");
    scr_port_assert(file_exists(_path), "migration keeps original");
    // A second startup never overwrites an already migrated save.
    scr_save_begin(_path);
    ini_write_real("Test", "Progress", 36);
    scr_save_finish(_path);
    scr_migrate_saves(_target, _dir);
    scr_port_assert(!scr_files_equal(_path, _target + "Stats.sav"), "idempotent migration");
    ini_open_from_string("[Test]\nBad=-5\nGood=42\n");
    scr_port_assert(scr_save_number("Test", "Bad", 0) == 0, "negative progress");
    scr_port_assert(scr_save_number("Test", "Good", 0) == 42, "valid progress");
    ini_close();
    level_selfcheck();
    scr_challenges_init();
    scr_lunarbase_selfcheck();
    global.hardmodeunlock = 0; global.world4 = 0;
    levelselect_selfcheck();
    commentary_selfcheck();
    CER_selection_selfcheck();
    scr_slope_geometry_selfcheck();
    scr_troop_nav_benchmark();
    scr_settings_selfcheck();
    scr_cosmetics_selfcheck();
    scr_cosmetics_runtime_selfcheck();
    scr_tradeup_selfcheck();
    scr_online_cosmetics_selfcheck();
    show_debug_message("TCC_PORT_SELF_CHECK_PASS");
    game_end();
}

function scr_mobile_touch_selfcheck() {
    var _bounds = platform_touch_bounds();
    platform_touch_defaults();
    scr_port_assert(global.androidrightx - global.androidleftx >= 192, "default movement controls do not overlap");
    for (var _size = 0; _size <= 2; ++_size) {
        global.androidbuttonsize = _size;
        scr_port_assert(platform_touch_layout_clear(platform_touch_layout().defaults, platform_touch_scale()), "default touch controls stay beside the playfield");
        scr_port_assert(platform_touch_at_defaults(platform_touch_layout().defaults), "default touch controls follow button size");
    }
    global.androidbuttonsize = 0;
    with (o_parentandroidbutton) {
        for (var _size = 0; _size <= 2; ++_size) {
            global.androidbuttonsize = _size;
            _bounds = platform_touch_bounds();
            platform_touch_position(-9999, -9999);
            scr_port_assert(abs(gui_x - sprite_width / 2 - _bounds[0] - 12) < 0.01, "whole scaled button stays inside left edge");
            scr_port_assert(abs(gui_y - sprite_height / 2 - _bounds[1] - 12) < 0.01, "whole scaled button stays inside top edge");
            platform_touch_position(9999, 9999);
            scr_port_assert(abs(gui_x + sprite_width / 2 - _bounds[2] + 12) < 0.01, "whole scaled button stays inside right edge");
            scr_port_assert(abs(gui_y + sprite_height / 2 - _bounds[3] + 12) < 0.01, "whole scaled button stays inside bottom edge");
        }
    }
    global.androidbuttonsize = 0;
    _bounds = platform_touch_bounds();
    with (o_buttonleftandroid) {
        platform_touch_position(512, 384);
        scr_port_assert(platform_touch_claim(0, 500, 380), "first button captures finger");
        platform_touch_move(500, 380);
        scr_port_assert(gui_x == 512 && gui_y == 384, "drag preserves contact offset");
    }
    with (o_buttonrightandroid) {
        platform_touch_position(512, 384);
        scr_port_assert(!platform_touch_claim(0, 500, 380), "overlapping button cannot capture same finger");
        scr_port_assert(platform_touch_claim(1, 500, 380), "second finger remains independent");
    }
    with (o_buttonleftandroid) platform_touch_move(-9999, 600);
    scr_port_assert(o_buttonrightandroid.gui_x == 512, "dragging one does not move overlapping button");
    if (_bounds[0] < -100) scr_port_assert(o_buttonleftandroid.gui_x < 0, "left control reaches side bar");
    with (o_buttonrightandroid) platform_touch_move(9999, 600);
    if (_bounds[2] > 1124) scr_port_assert(o_buttonrightandroid.gui_x > 1024, "right control reaches side bar");
    var _saved_left = global.androidleftx;
    var _saved_right = global.androidrightx;
    global.androidbuttonsize = 2;
    scr_saveandroid(); scr_loadandroid();
    scr_port_assert(global.androidleftx == _saved_left && global.androidrightx == _saved_right && global.androidbuttonsize == 2, "side bar placement and button size survive reload");
    platform_clear_input();
    with (o_parentandroidbutton) scr_port_assert(my_touch == -1, "interruption releases drag ownership");
    var _path = directory_set("/Save Files/") + "Android.sav";
    scr_save_begin(_path);
    ini_write_real("Android", "Left X", 120); ini_write_real("Android", "Right X", 140);
    ini_write_real("Android", "Left Y", 640); ini_write_real("Android", "Right Y", 640);
    scr_save_finish(_path); scr_loadandroid();
    scr_port_assert(global.androidrightx - global.androidleftx >= 192, "legacy overlapping layout repaired");
    platform_touch_defaults(); scr_saveandroid();
    show_debug_message("TCC_TOUCH_LAYOUT_PASS " + json_stringify(_bounds));
}

// iOSCheck runs real room transitions in a separate simulator app/save container.
function scr_mobile_smoke_step() {
    if (!variable_global_exists("mobile_smoke_stage")) {
        if (room != r_mainmenu) return;
        global.mobile_smoke_stage = 0;
        global.mobile_smoke_frames = 0;
        global.mobile_smoke_view = "main_menu";
    }
    if (global.mobile_smoke_stage < 0) return;
    ++global.mobile_smoke_frames;
    // Capture an already-rendered, settled view rather than a transition frame.
    if (global.mobile_smoke_frames == 45 && global.mobile_smoke_view != "") {
        show_debug_message("TCC_MOBILE_VIEW " + global.mobile_smoke_view);
        global.mobile_smoke_view = "";
    }
    if (global.mobile_smoke_frames < 225) return;
    global.mobile_smoke_frames = 0;
    show_debug_message("TCC_MOBILE_SMOKE_STAGE " + string(global.mobile_smoke_stage));
    switch (global.mobile_smoke_stage++) {
        case 0:
            startnewgame();
            break;
        case 1:
            scr_port_assert(room == r_lvl1 && instance_exists(o_player), "new game reaches first level");
            scr_port_assert(file_exists(directory_set("/Save Files/") + "SaveFile.sav"), "campaign save created");
            hidehud(); hideandroidbuttons(); room_goto(r_mainmenu);
            break;
        case 2:
            with (o_load) event_perform(ev_mouse, ev_left_press);
            break;
        case 3:
            scr_port_assert(room == r_lvl1 && instance_exists(o_player), "continue reaches saved level");
            hidehud(); hideandroidbuttons(); room_goto(r_funmodemenu);
            break;
        case 4:
            with (o_endlessbutton) event_perform(ev_mouse, ev_left_press);
            break;
        case 5:
            scr_port_assert(room == r_endlessrunmenu, "endless menu opens without Steam");
            with (o_endlessbutton) event_perform(ev_mouse, ev_left_press);
            break;
        case 6:
            scr_port_assert(global.endless == 1 && instance_exists(o_player), "endless run starts");
            hidehud(); hideandroidbuttons(); global.endless = 0; global.pause = 0;
            room_goto(r_settings);
            break;
        case 7:
            with (o_settingbutton) {
                if (setting_type == STYPE.CATEGORY && setting_target_menu == 3)
                    event_perform(ev_mouse, ev_left_press);
            }
            global.mobile_smoke_view = "settings_controls";
            break;
        case 8:
            scr_port_assert(global.choosesettings == 3, "controls category opens");
            with (o_settingbutton) {
                if (setting_type == STYPE.CATEGORY && setting_target_menu == 7)
                    event_perform(ev_mouse, ev_left_press);
            }
            scr_port_assert(global.choosesettings == 7, "touch layout editor opens");
            scr_port_assert(instance_exists(o_buttonleftandroid) && instance_exists(o_buttonjumpandroid), "touch controls created");
            scr_mobile_touch_selfcheck();
            global.fpssettings = 1;
            if (!instance_exists(o_fpscounter)) instance_create(0, 0, o_fpscounter);
            hideandroidbuttons(); global.choosesettings = 0; room_goto(r_gamemode);
            global.mobile_smoke_view = "gamemode";
            break;
        case 9:
            scr_port_assert(room == r_gamemode && instance_exists(o_creditscounter) && instance_exists(o_returnbutton), "game mode menu has credits and Return");
            var _credits = instance_find(o_creditscounter, 0), _return = instance_find(o_returnbutton, 0);
            var _return_x = _return.x - camera_get_view_x(view_camera[0]);
            var _return_y = _return.y - camera_get_view_y(view_camera[0]);
            scr_port_assert(_credits.p2 + 12 <= _return_x || _credits.p1 >= _return_x + _return.sprite_width + 12
                || _credits.p4 + 12 <= _return_y || _credits.p3 >= _return_y + _return.sprite_height + 12,
                "credits counter stays clear of Return");
            scr_port_assert(instance_exists(o_fpscounter), "game mode capture exercises the enabled FPS overlay");
            global.fpssettings = 0;
            instance_destroy(o_fpscounter);
            instance_create(0, 0, o_progressask);
            break;
        case 10:
            scr_port_assert(instance_exists(o_progressask), "mobile confirmation opens");
            with (o_progressask) {
                mobile_confirmation_submit(ord("N"));
                scr_port_assert(instance_exists(o_progressask), "No stays queued until a logical tick");
                confirmation_tick_update();
            }
            scr_port_assert(!instance_exists(o_progressask), "No dismisses confirmation");
            scr_port_assert(room == r_gamemode, "No preserves current room");
            instance_create(0, 0, o_progressask);
            break;
        case 11:
            with (o_progressask) {
                mobile_confirmation_submit(ord("Y"));
                confirmation_tick_update();
            }
            break;
        case 12:
            scr_port_assert(room == r_lvl1 && instance_exists(o_player), "Yes starts campaign without URL action");
            scr_port_assert(!instance_exists(o_buttonandroidyes) && !instance_exists(o_buttonandroidno), "no orphan confirmation controls");
            scr_mobile_input_selfcheck();
            show_debug_message("TCC_TOUCH_VIEW " + json_stringify({window: [window_get_width(), window_get_height()],
                wanted: platform_touch_composite_wanted(), composited: platform_touch_composited(),
                surface: platform_app_surface_rect(), gui: platform_touch_gui_rect(), position: application_get_position(),
                fraction: platform_touch_layout().fraction, bounds: platform_touch_layout().bounds}));
            global.mobile_smoke_view = "gameplay_100";
            break;
        case 13:
            scr_mobile_layout_probe();
            global.androidbuttonsize = 1;
            platform_touch_layout();
            global.mobile_smoke_view = "gameplay_125";
            break;
        case 14:
            scr_mobile_layout_probe();
            global.androidbuttonsize = 2;
            platform_touch_layout();
            global.mobile_smoke_view = "gameplay_150";
            break;
        case 15:
            scr_mobile_layout_probe();
            platform_touch_defaults();
            platform_touch_begin();
            global.mobile_smoke_pause_position = scr_mobile_pause_position();
            scr_mobile_pause_probe();
            global.mobile_smoke_view = "pause_touch";
            break;
        case 16:
            scr_port_assert(global.pause == 1 && instance_exists(o_pausescreen), "touch pause opens menu");
            scr_mobile_pause_position_check();
            scr_mobile_pause_probe();
            break;
        case 17:
            scr_port_assert(global.pause == 0 && instance_exists(o_buttonskipandroid), "resume restores all gameplay controls");
            scr_mobile_pause_position_check();
            global.special = 123456;
            platform_interrupt();
            global.mobile_smoke_view = "pause_background";
            break;
        case 18:
            scr_port_assert(global.pause == 1, "background interruption pauses");
            scr_port_assert(instance_number(o_parentandroidbutton) == 1, "background pause shows only the resume control");
            scr_mobile_pause_position_check();
            with (o_settings) event_perform(ev_mouse, ev_left_press);
            global.mobile_smoke_view = "settings_general";
            break;
        case 19:
            scr_port_assert(instance_exists(o_settingspausemenu), "pause settings opens");
            scr_port_assert(instance_number(o_parentandroidbutton) == 0, "pause settings removes every gameplay control");
            with (o_settingbutton) {
                if (setting_type == STYPE.CATEGORY && setting_target_menu == 2)
                    event_perform(ev_mouse, ev_left_press);
            }
            global.mobile_smoke_view = "settings_audio";
            break;
        case 20:
            scr_port_assert(global.choosesettings == 2, "audio category opens");
            scr_back();
            break;
        case 21:
            with (o_settingbutton) {
                if (setting_type == STYPE.CATEGORY && setting_target_menu == 3)
                    event_perform(ev_mouse, ev_left_press);
            }
            global.mobile_smoke_view = "settings_controls_paused";
            break;
        case 22:
            scr_port_assert(global.choosesettings == 3 && !instance_exists(o_buttonleftandroid), "controls settings do not overlap touch controls");
            with (o_settingbutton) {
                if (setting_type == STYPE.CATEGORY && setting_target_menu == 7)
                    event_perform(ev_mouse, ev_left_press);
            }
            global.mobile_smoke_view = "settings_touch_layout";
            break;
        case 23:
            scr_port_assert(global.choosesettings == 7 && instance_exists(o_buttonleftandroid), "pause touch layout is editable");
            scr_back();
            scr_port_assert(global.choosesettings == 3 && !instance_exists(o_buttonleftandroid), "touch layout returns to controls settings");
            scr_back();
            with (o_settingspausemenu) event_perform(ev_keyrelease, vk_escape);
            break;
        case 24:
            scr_port_assert(!instance_exists(o_settingspausemenu) && global.pause == 1, "settings returns to pause");
            scr_port_assert(instance_exists(o_buttonpauseandroid), "keyboard settings exit restores touch resume");
            scr_mobile_pause_probe();
            global.mobile_smoke_view = "gameplay_large_balance";
            break;
        case 25:
            scr_port_assert(global.pause == 0, "gameplay resumes after settings");
            scr_mobile_layout_probe();
            show_debug_message("TCC_MOBILE_SMOKE_PASS");
            global.mobile_smoke_stage = -1;
            break;
    }
}

function scr_mobile_pause_position() {
    var _p = instance_find(o_buttonpauseandroid, 0);
    scr_port_assert(instance_exists(_p), "pause control exists");
    var _g = platform_touch_to_gui(_p.gui_x, _p.gui_y), _r = platform_touch_gui_rect();
    return [_r[0] + _g[0] * _r[2], _r[1] + _g[1] * _r[3]];
}

function scr_mobile_pause_position_check() {
    var _p = scr_mobile_pause_position(), _before = global.mobile_smoke_pause_position;
    scr_port_assert(point_distance(_p[0], _p[1], _before[0], _before[1]) < 1, "pause control keeps its screen position");
}

function scr_mobile_pause_probe() {
    global.touch_blocked = false;
    platform_touch_begin();
    var _p = instance_find(o_buttonpauseandroid, 0);
    var _g = platform_touch_to_gui(_p.gui_x + _p.sprite_width / 2, _p.gui_y + _p.sprite_height / 2);
    var _point = platform_touch_from_gui(_g[0], _g[1]);
    platform_touch_sample(0, _point[0], _point[1], true, false);
    scr_port_assert(_p.press, "rendered pause target reaches input routing");
    with (_p) event_perform(ev_step, ev_step_normal);
}

function scr_mobile_layout_probe() {
    scr_port_assert(platform_touch_layout_clear(platform_touch_layout().defaults, platform_touch_scale()), "active layout leaves gameplay unobstructed");
    var _buttons = [];
    with (o_parentandroidbutton) {
        var _g = platform_touch_to_gui(gui_x, gui_y);
        var _point = platform_touch_from_gui(_g[0], _g[1]);
        scr_port_assert(point_distance(_point[0], _point[1], gui_x, gui_y) < 0.01, "rendered controls map back to touch positions");
        array_push(_buttons, {name: object_get_name(object_index), x: gui_x, y: gui_y, width: sprite_width, height: sprite_height});
    }
    show_debug_message("TCC_MOBILE_LAYOUT " + json_stringify({size: global.androidbuttonsize, window: [window_get_width(), window_get_height()],
        rect: platform_touch_layout().rect, gui: platform_touch_gui_rect(), buttons: _buttons}));
}

// Deterministic contact-frame regression checks in the isolated iOSCheck app.
function scr_mobile_input_selfcheck() {
    platform_touch_defaults();
    platform_clear_input();
    global.touch_blocked = false;
    var _jump = instance_find(o_buttonjumpandroid, 0);
    var _left = instance_find(o_buttonleftandroid, 0);
    var _right = instance_find(o_buttonrightandroid, 0);
    var _interact = instance_find(o_buttoninteractandroid, 0);
    platform_touch_begin();
    platform_touch_sample(0, _left.gui_x, _left.gui_y, true, false);
    platform_touch_sample(1, _jump.gui_x, _jump.gui_y, true, false);
    scr_port_assert(_left.pressed && _jump.press, "move and jump accept independent fingers in the same frame");
    with (o_player) event_perform(ev_step, ev_step_normal);
    scr_port_assert(o_player.vsp < 0 && o_player.key_left, "sampled jump and movement reach gameplay immediately");

    platform_touch_begin();
    platform_touch_sample(1, _jump.gui_x, _jump.gui_y, false, false);
    scr_port_assert(_jump.pressed && !_jump.press && !_left.pressed, "holding does not repeat an edge; released movement stops");
    platform_touch_begin();
    platform_touch_sample(1, _jump.gui_x, _jump.gui_y, true, false);
    scr_port_assert(_jump.press, "rapid native re-tap survives without an intervening empty frame");
    o_player.doublejump = 1;
    o_player.vsp = 0;
    with (o_player) event_perform(ev_step, ev_step_normal);
    scr_port_assert(o_player.doublejump == 0 && o_player.vsp < 0, "rapid second tap consumes the airborne double jump");

    platform_touch_begin();
    platform_touch_sample(1, _jump.gui_x, _jump.gui_y, false, false);
    platform_touch_sample(2, _jump.gui_x, _jump.gui_y, true, false);
    scr_port_assert(_jump.press && _jump.touch_mask == 6, "second finger can tap an already-held action");
    platform_touch_begin();
    platform_touch_sample(1, _jump.gui_x, _jump.gui_y, false, false);
    scr_port_assert(_jump.pressed && !_jump.press, "lifting one finger does not release the other");
    platform_touch_begin();
    platform_touch_sample(1, _jump.gui_x + _jump.sprite_width / 2 + 20, _jump.gui_y, false, false);
    scr_port_assert(_jump.pressed && !_jump.press, "thumb drift outside the artwork keeps the existing hold");
    platform_touch_begin();
    scr_port_assert(!_jump.pressed && !_jump.press, "release clears an action on the next sample");

    platform_touch_sample(0, _left.gui_x, _left.gui_y, true, false);
    platform_touch_begin();
    platform_touch_sample(0, _right.gui_x, _right.gui_y, false, false);
    scr_port_assert(!_left.pressed && _right.pressed, "movement slides directly from left to right");
    global.androidleftx = 512; global.androidrightx = 552;
    platform_touch_begin();
    platform_touch_sample(0, _right.gui_x, _right.gui_y, true, false);
    scr_port_assert(!_left.pressed && _right.pressed, "overlapping controls route one finger to the nearest target");
    platform_touch_defaults();

    platform_clear_input();
    platform_touch_begin();
    platform_touch_sample(0, _jump.gui_x, _jump.gui_y, true, false);
    scr_port_assert(!_jump.press && !_jump.pressed, "interruption blocks held and pressed state");
    global.touch_blocked = false;
    global.mobile_background = true;
    platform_touch_sample(0, _jump.gui_x, _jump.gui_y, true, false);
    scr_port_assert(!_jump.press, "background input cannot activate gameplay");
    global.mobile_background = false;
    global.pause = 1;
    platform_touch_begin();
    platform_touch_sample(0, _jump.gui_x, _jump.gui_y, true, false);
    var _pause = instance_find(o_buttonpauseandroid, 0);
    platform_touch_sample(1, _pause.gui_x, _pause.gui_y, true, false);
    scr_port_assert(!_jump.press && _pause.press, "paused gameplay is blocked but a second finger can resume");
    global.pause = 0;

    platform_touch_begin();
    platform_touch_sample(0, _interact.gui_x, _interact.gui_y, true, false);
    with (o_player) event_perform(ev_step, ev_step_normal);
    var _spiral = instance_create(o_player.x, o_player.y, o_yellowspiral);
    global.pause = 1;
    with (o_player) event_perform(ev_collision, o_yellowspiral);
    scr_port_assert(instance_exists(_spiral), "paused collision does not consume a pickup");
    global.pause = 0;
    with (o_player) event_perform(ev_collision, o_yellowspiral);
    scr_port_assert(!instance_exists(_spiral) && global.color == 1, "quick sampled interact activates the spiral");
    platform_clear_input();
    show_debug_message("TCC_TOUCH_INPUT_PASS");
}
