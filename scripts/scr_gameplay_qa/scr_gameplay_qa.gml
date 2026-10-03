/// Diagnostic input playback is compiled into the QA configuration only.
/// It observes the real player and exit events; it never moves the player or awards a win.
function qa_active() {
    return TCC_GAMEPLAY_QA && variable_global_exists("tcc_qa") && is_struct(global.tcc_qa);
}

function tcc_randomize() {
    // Production retains the original reseeding behavior. QA owns the seed so
    // object Create/Step events cannot silently invalidate a recording.
    if (!TCC_GAMEPLAY_QA) randomize();
}

function qa_value(_record, _name, _fallback) {
    return is_struct(_record) && variable_struct_exists(_record, _name)
        ? variable_struct_get(_record, _name) : _fallback;
}

function qa_local_multiplayer() {
    return qa_active() && qa_value(global.tcc_qa.spec, "actor", "") == "local-multiplayer";
}

function qa_player_object() {
    return qa_local_multiplayer() ? o_playerMU : o_player;
}

function qa_boot() {
    if (!TCC_GAMEPLAY_QA || qa_active()) return;
    platform_master_gain(0);
    var _file = environment_get_variable("TCC_QA_SPEC");
    show_debug_message("QA argument count: " + string(parameter_count()));
    for (var _i = 1; _i <= parameter_count(); _i++) {
        var _arg = parameter_string(_i);
        show_debug_message("QA argument " + string(_i) + ": " + _arg);
        if (string_pos("--tcc-qa=", _arg) == 1) _file = string_delete(_arg, 1, 9);
    }
    if (_file == "" || !file_exists(_file)) {
        show_debug_message("TCC_GAMEPLAY_QA_ERROR: supply --tcc-qa=/absolute/spec.json");
        game_end(); return;
    }
    try {
        var _spec = level_parse_json_file(_file);
        if (!is_struct(_spec)) throw "Invalid QA specification";
        if (variable_struct_exists(_spec, "specialIndex")) throw "Special levels are excluded from this build";
        if (qa_value(_spec, "actor", "") == "local-multiplayer"
            && (qa_value(_spec, "room", "") != "r_gameplay_qa"
                || variable_struct_exists(_spec, "specialIndex") || variable_struct_exists(_spec, "challenge")))
            throw "Local multiplayer diagnostics require the calibration room";
        var _fps = qa_value(_spec, "fps", 0);
        if (!is_real(_fps) || is_nan(_fps) || is_infinity(_fps)
            || _fps != floor(_fps) || _fps < 30 || _fps > 1000) throw "Unsupported FPS";
        if (qa_value(_spec, "inputClock", "") != TCC_INPUT_CLOCK
            || qa_value(_spec, "simulationHz", 0) != TCC_SIM_HZ) throw "Missing or unsupported simulation clock";
        if (!array_contains(["replay", "record", "route"], qa_value(_spec, "mode", "replay"))) throw "Unsupported input mode";
        if (!is_string(qa_value(_spec, "output", undefined)) ||
            !is_string(qa_value(_spec, "saveRoot", undefined))) throw "Missing isolated paths";
        var _events = qa_value(_spec, "inputs", []);
        if (!is_array(_events)) throw "Inputs must be an ordered array";
        var _timing_scenario = qa_value(_spec, "timingScenario", undefined);
        if (!is_undefined(_timing_scenario)) {
            if (!is_struct(_timing_scenario)
                || !array_contains(["pause-input-v1", "platform-interrupt-v1"], qa_value(_timing_scenario, "kind", ""))
                || qa_value(_spec, "mode", "replay") != "replay"
                || qa_value(_spec, "room", "") != "r_gameplay_qa"
                || qa_value(_spec, "actor", "") == "local-multiplayer"
                || variable_struct_exists(_spec, "challenge") || variable_struct_exists(_spec, "specialIndex")
                || variable_struct_exists(_spec, "timingProbe")) throw "Invalid isolated pause scenario";
            if (_timing_scenario.kind == "platform-interrupt-v1") {
                var _interrupt_frame = qa_value(_timing_scenario, "interruptFrame", -1);
                if (!level_finite(_interrupt_frame) || is_bool(_interrupt_frame) || _interrupt_frame != floor(_interrupt_frame)
                    || _interrupt_frame < 1 || _interrupt_frame >= qa_value(_spec, "maxFrames", 0))
                    throw "Invalid production interruption observation frame";
            }
        }
        var _route_start = qa_value(_spec, "routeStartFrame", 0);
        if (!is_real(_route_start) || is_bool(_route_start) || is_nan(_route_start) || is_infinity(_route_start)
            || _route_start < 0 || _route_start != floor(_route_start)) throw "Invalid route start frame";
        if (_route_start > 0 && qa_value(_spec, "mode", "replay") != "route") throw "Input prefixes require route mode";
        var _last_frame = -1;
        for (var _e = 0; _e < array_length(_events); _e++) {
            var _event = _events[_e];
            if (!is_struct(_event) || !level_finite(qa_value(_event, "frame", undefined)) ||
                !level_finite(qa_value(_event, "mask", undefined)) ||
                is_bool(_event.frame) || is_bool(_event.mask)) throw "Invalid input event";
            if (_event.frame <= _last_frame || _event.frame != floor(_event.frame) ||
                _event.mask < 0 || _event.mask > 63 || _event.mask != floor(_event.mask)) throw "Invalid input order/mask";
            _last_frame = _event.frame;
            if (_route_start > 0 && _event.frame >= _route_start) throw "Input prefix overlaps route start";
        }
        if (variable_struct_exists(_spec, "manualCameraCandidate")
            && !is_bool(_spec.manualCameraCandidate)) throw "Manual camera selection must be boolean";
        var _sequence_probe_validation = sequence_probe_qa_validate(_spec);
        if (!_sequence_probe_validation.valid) throw _sequence_probe_validation.error;
        var _credits_validation = credits_presentation_qa_validate(_spec);
        if (!_credits_validation.valid) throw _credits_validation.error;
        var _follow_validation = camera_follow_qa_validate(_spec);
        if (!_follow_validation.valid) throw _follow_validation.error;
        global.tcc_qa = {
            spec: _spec, fps: _fps, seed: qa_value(_spec, "seed", 1),
            save_root: _spec.saveRoot, output: _spec.output,
            mode: qa_value(_spec, "mode", "replay"), inputs: _events,
            events: [], trace: [], recorded: [], index: 0, mask: 0, previous: 0,
            frame: 0, started: false, running: false, finished: false, tick_input: false, draw_calls:0,
            preparing:is_struct(qa_value(_spec, "timingProbe", undefined)), preparation:undefined,
            pause_observations:[], interrupt_invoked:false, captures:[], captures_truncated:false,
            initial: undefined, last: undefined, goal: undefined, deaths: 0,
            invalid: "", start_us: 0, step_us: 0, step_costs: [], frame_deltas: [],
            render_frames:0, render_frame_deltas:[], render_us:0, simulation_us:0,
            lowest_y: 1000000000, highest_y: -1000000000, minimum_x: 1000000000, maximum_x: -1000000000,
            wait_frames: 0, recovery_pending: true,
            goal_player_id:noone,
            route_index: 0, route_frame: _route_start, route_jump: false, route_airjump: false, route_deaths: 0
        };
        directory_create(_spec.saveRoot);
        random_set_seed(global.tcc_qa.seed);
    } catch (_error) {
        show_debug_message("TCC_GAMEPLAY_QA_ERROR: " + string(_error));
        game_end();
    }
}

function qa_apply_fps() {
    if (!qa_active()) return;
    global.maxfps = TCC_SIM_HZ;
    global.renderfps = global.tcc_qa.fps;
    timing_apply_render_rate();
}

// Observe practice records/rewards in the isolated profile. These are copied
// values, so a later results screen cannot rewrite the captured baseline.
function qa_practice_progress(_id) {
    var _def = scr_challenge_get_def(_id);
    var _skins = [], _hats = [], _achievements = [];
    var _ids = array_concat(_def.reward_skins, _def.bonus_skins);
    for (var _i = 0; _i < array_length(_ids); ++_i)
        array_push(_skins, {id:_ids[_i], owned:global.skin[_ids[_i]]});
    if (_def.reward_hat >= 0) array_push(_hats, {id:_def.reward_hat, owned:global.hat[_def.reward_hat]});
    var _awards = [_def.achievement, "FIRST_CHALLENGE", "PERFECT_CHALLENGE", "THE_ANTI_DEATH"];
    for (var _i = 0; _i < array_length(_awards); ++_i)
        if (_awards[_i] != "") array_push(_achievements, {id:_awards[_i], earned:achievement_earned(_awards[_i])});
    return {time:scr_challenge_get_time(_id), deaths:scr_challenge_get_deaths(_id),
        credits:global.creditscurrency, skins:_skins, hats:_hats, achievements:_achievements};
}

function qa_launch_levelselect(_selection) {
    var _q = global.tcc_qa;
    var _id = qa_value(_selection, "challenge", -1), _number = qa_value(_selection, "level", -1);
    if (!level_finite(_id) || _id != floor(_id) || _id < 0
        || !level_finite(_number) || _number != floor(_number) || _number < 1) return false;
    var _def = scr_challenge_get_def(_id);
    if (is_undefined(_def) || _def.enabled != 1) return false;
    // World unlocks are explicit isolated start conditions. DLC/skin ownership
    // stays subject to the actual production entry's unlock check.
    global.world1 = 1; global.world2 = 1; global.world3 = 1; global.world4 = 1; global.world5 = 1;
    var _pages = get_levelselect_pages(), _entry = undefined;
    for (var _p = 0; _p < array_length(_pages); ++_p) {
        for (var _i = 0; _i < array_length(_pages[_p].levels); ++_i) {
            var _candidate = _pages[_p].levels[_i];
            if (_candidate.is_challenge && _candidate.challenge_id == _id && _candidate.level_num == _number)
                _entry = _candidate;
        }
    }
    if (is_undefined(_entry) || !levelselect_unlocked(_entry)
        || room_get_name(_entry.roomselect) != qa_value(_q.spec, "room", "")) return false;
    // Seed observable prior records rather than letting a zero/default baseline
    // hide an accidental practice write. This never changes the playable room.
    var _key = scr_challenge_key(_id);
    global.challenge_times[? _key] = 1234.5;
    global.challenge_deaths[? _key] = 42;
    if (_def.time_var != "") variable_global_set(_def.time_var, 1234.5);
    if (_def.deaths_var != "") variable_global_set(_def.deaths_var, 42);
    global.creditscurrency = 123;
    var _ids = array_concat(_def.reward_skins, _def.bonus_skins);
    for (var _i = 0; _i < array_length(_ids); ++_i) global.skin[_ids[_i]] = 0;
    if (_def.reward_hat >= 0) global.hat[_def.reward_hat] = 0;
    _q.practice_observation = {challenge:_id, level:_number, room:room_get_name(_entry.roomselect),
        sequenceIndex:_entry.sequence_index, before:qa_practice_progress(_id)};
    if (!levelselect_start(_entry)) return false;
    _q.practice_observation.afterLaunch = {practice:global.levelselect == 1,
        runId:global.challenge_run_id, eligible:scr_challenge_run_eligible(_id)};
    return true;
}

function qa_launch() {
    if (!qa_active()) return;
    var _q = global.tcc_qa;
    qa_apply_fps();
    global.pause = 0;
    global.cheats = 0;
    global.noclip = 0;
    global.easy = 0;
    global.managablejump = 0;
    global.visiblethings = 0;
    global.infinitelivessettings = 0;
    global.writingmode = 0;
    global.hardmode = 0;
    global.levelselect = 0;
    global.challenges = 0;
    global.endless = 0;
    global.workshop = 0;
    global.workshopchallenge = 0;
    global.calendar = 0;
    global.dailylevel = 0;
    global.time = 0;
    global.deaths = 0;
    global.pickup = 0;
    // Direct campaign-room diagnostics bypass the title/new-game screens. Use
    // their fresh-run state before room Create events save or inspect it.
    global.special = 0;
    global.checkdeposit = false;
    global.boss1 = 0; global.boss2 = 0; global.boss3 = 0;
    global.boss4 = 0; global.boss5 = 0;
    global.boss2health = 6;
    global.world1time = 0; global.world2time = 0; global.world3time = 0;
    global.world4time = 0; global.world5time = 0;
    global.hatmerchantdiscount = 1;
    global.level100trap = 0;
    global.endlessmusicchange = 10;
    global.endless1upchange = 10;
    global.CUSTOMskin = "";
    global.CUSTOMhat = "";
    global.CUSTOMitem = "";
    var _cosmetics = qa_value(_q.spec, "cosmetics", undefined);
    if (is_struct(_cosmetics)) {
        if (!cosmetics_enabled()) { qa_finish("invalid", "File cosmetics are desktop only"); return; }
        var _kinds = ["skin", "hat", "item"];
        for (var _c = 0; _c < array_length(_kinds); ++_c) {
            var _kind = _kinds[_c], _name = qa_value(_cosmetics, _kind, "");
            if (_name != "" && !cosmetics_validate(_kind, _name).ok) {
                qa_finish("invalid", "Invalid isolated cosmetic fixture"); return;
            }
            variable_global_set("CUSTOM" + _kind, _name);
        }
    }
    global.skinselected = 0;
    global.hatselected = 0;
    global.playerpar = 1;
    global.autopausesettings = 0;
    if (qa_local_multiplayer()) {
        // The same lobby defaults used for one observed local race player.
        global.MinigameMU = 2;
        global.playersleft = 1;
        global.racescore = [0, 0, 0, 0];
        global.multiplayerplayercontrols = [0, 1, 2, 3, -4];
        global.multiplayerplayerskin = [0, 0, 0, 0];
        global.multiplayerplayerhat = [0, 0, 0, 0];
        global.multiplayerplayeritem = [0, 0, 0, 0];
    }
    scr_resetcheckpointdata();
    random_set_seed(_q.seed);
    _q.running = true;
    timing_create_depth(0, 0, -100000, o_gameplay_qa);
    if (credits_presentation_qa_launch()) return;
    var _challenge = qa_value(_q.spec, "challenge", -1);
    if (variable_struct_exists(_q.spec, "levelSelect")) {
        if (_challenge >= 0 || qa_local_multiplayer()
            || !qa_launch_levelselect(_q.spec.levelSelect)) {
            qa_finish("invalid", "Invalid or locked production level-select entry");
        }
    } else if (_challenge >= 0) {
        // Unlocks are start conditions in this isolated profile, not changes to
        // the playable level, pickups, collision, or timer.
        global.world1 = 1; global.world2 = 1; global.world3 = 1; global.world4 = 1;
        scr_challenge_start(_challenge);
    } else {
        var _room = asset_get_index(qa_value(_q.spec, "room", "r_gameplay_qa"));
        if (_room == -1 || !room_exists(_room)) { qa_finish("invalid", "Unknown room"); return; }
        room_goto(_room);
        loadhud();
    }
}

function qa_snapshot(_p) {
    var _mu = _p.object_index == o_playerMU;
    var _sample = {
        frame: global.tcc_qa.frame, room: room_get_name(room),
        actor: object_get_name(_p.object_index),
        x: _p.x, y: _p.y, hsp: _p.hsp, vsp: _p.vsp,
        direction:_p.direction, motionSpeed:_p.speed,
        sprite: sprite_get_name(_p.sprite_index), animationFrame:_p.image_index,
        animationVelocity:_p.animation_vsp, eyesY:_p.eyesY,
        gravity: _p.grv, walkSpeed: _p.walksp, color: _mu ? _p.color : global.color,
        grounded: _p.onGround, water: _p.inwater, breath: _p.breath,
        doubleJump: _p.doublejump, zeroGravity: _p.zerogrv,
        ammo: _mu ? _p.ammo : global.gunammo, keysRemaining: instance_number(o_key),
        challengeTime: global.time, challengeDeaths: global.deaths, paused:global.pause != 0,
        challengeRunId: global.challenge_run_id, challengePractice: global.levelselect != 0,
        endlessMode: global.endless ? global.endlessrunmode : 0,
        endlessLevel: global.endlesslevel, lives: global.hardmodelives,
        cheats: global.cheats, revealHidden: global.visiblethings, seed: random_get_seed(),
        bbox: [_p.bbox_left, _p.bbox_top, _p.bbox_right, _p.bbox_bottom],
        slopeContact: qa_slope_snapshot(_p), slopeOverlap:qa_slope_body_overlap(_p)
    };
    if (is_struct(qa_value(global.tcc_qa.spec, "cosmetics", undefined))) {
        _sample.cosmetics = {skin:_p.customskin, hat:_p.customhat, item:_p.customitem,
            mask:sprite_get_name(_p.mask_index), cachedAssets:array_length(global.cosmetic_assets),
            skinFrames:_p.customskin ? sprite_get_number(_p.customskin_spr) : 0,
            skinOrigin:_p.customskin ? [sprite_get_xoffset(_p.customskin_spr), sprite_get_yoffset(_p.customskin_spr)] : undefined,
            hatFrames:_p.customhat ? sprite_get_number(_p.curhat) : 0,
            itemFrames:_p.customitem ? sprite_get_number(_p.customitem_spr) : 0};
        var _refs = 0;
        for (var _c = 0; _c < array_length(global.cosmetic_assets); ++_c)
            _refs += global.cosmetic_assets[_c].refs;
        _sample.cosmetics.liveReferences = _refs;
    }
    return _sample;
}

// Record the normal mapped inputs even while the player is paused or absent.
// This reader has no physics fields or actor identity and never moves anything.
function qa_record_input_mask() {
    var _mask = 0;
    var _reader = {doublejump:0};
    with (_reader) {
        scr_player_input();
        _mask = (key_left ? 1 : 0) | (key_right ? 2 : 0) |
            (input_jump_held ? 4 : 0) | (key_interact_h ? 8 : 0) | (key_restart ? 16 : 0);
    }
    return _mask;
}

// Recording uses the action actually dispatched by the normal pause system.
// Touch has its own dispatcher and must not also toggle the keyboard system.
function qa_record_pause_action(_source) {
    if (!qa_active()) return;
    var _q = global.tcc_qa;
    if (!_q.running || _q.finished || _q.mode != "record") return;
    // A dispatched action before the first player tick has no initialized
    // recording state. Reject it instead of silently producing another replay.
    if (!_q.started) {
        _q.invalid = "Pause action occurred before recording initialization";
        return;
    }
    if (!timing_is_tick()) return;
    if ((_q.mask & 32) != 0 || (_q.previous & 32) != 0) {
        // Version 2 stores a rising pause bit. Two actions in one tick or in
        // consecutive ticks cannot be encoded faithfully; reject that record.
        _q.invalid = "Pause actions cannot be represented by input mask version 2";
        return;
    }
    _q.mask |= 32;
    array_push(_q.events, {kind:"recorded-pause-action", source:_source, frame:_q.frame});
}

function qa_pause_observe() {
    var _q = global.tcc_qa;
    if (!is_struct(qa_value(_q.spec, "timingScenario", undefined))
        && !qa_value(_q.spec, "observeRecovery", false)) return;
    var _t = global.tcc_timing;
    var _clock = instance_find(o_time, 0);
    var _player = instance_find(qa_player_object(), 0);
    array_push(_q.pause_observations, {frame:_q.frame, mask:_q.mask,
        observationPhase:"root-end", nativeEventType:event_type, nativeEventNumber:event_number,
        roomGeneration:_t.room_generation, room:room_get_name(room),
        isSimulationTick:_t.tick, beginPending:_t.begin_pending,
        livePlayers:instance_number(o_player), localPlayers:instance_number(o_playerMU),
        deadPlayers:instance_number(o_playerdead), challengeDeaths:global.deaths,
        tickId:timing_tick_id(), renderId:timing_render_id(), elapsedUs:get_timer()-_q.start_us,
        paused:global.pause != 0, inputApplied:_q.tick_input,
        playerPresent:_player != noone, player:_player != noone ? qa_snapshot(_player) : undefined,
        pauseController:instance_exists(o_pausesystem) != 0, pauseScreen:instance_exists(o_pausescreen) != 0,
        returnButton:instance_exists(o_returnbutton) != 0, challengeTime:global.time,
        settingsButton:instance_exists(o_settings) != 0, feedbackButton:instance_exists(o_givefeedback) != 0,
        restartButton:instance_exists(o_restartchallengebutton) != 0,
        pausedWallSeconds:_clock != noone ? _clock.pausetime : undefined,
        outerElapsedUs:_t.elapsed_us, accumulatorUs:_t.accumulator_us,
        previousPauseApplied:_t.clock_pause_applied, resumeBoundaryApplied:_t.clock_resume_applied,
        backgroundBoundaryApplied:_t.clock_background_applied, accumulatorBeforeUs:_t.clock_accumulator_before_us,
        pauseClockAfterEnd:_t.pause_clock, resumeBoundaryLatched:_t.resume_boundary,
        interruptSerial:_t.interrupt_serial, consumedInterruptSerial:_t.consumed_interrupt_serial,
        interruptConsumption:_t.interrupt_consumption});
}

function qa_begin_step() {
    if (!qa_active()) return;
    var _q = global.tcc_qa;
    if (!_q.running || _q.finished) return;
    _q.tick_input = false;
    if (!timing_is_tick()) return;
    _q.step_us = get_timer();
    if (credits_presentation_qa_active()) return;
    if (!is_undefined(_q.goal)) return;
    if (_q.preparing) return;
    if (_q.mode == "record") {
        // Local multiplayer retains its own five-action reader in player Step.
        _q.mask = qa_local_multiplayer() ? (_q.mask & 31)
            : qa_record_input_mask();
    }
    if (_q.mode == "replay" || (_q.mode == "route" && _q.frame < qa_value(_q.spec, "routeStartFrame", 0))) {
        while (_q.index < array_length(_q.inputs) && _q.inputs[_q.index].frame <= _q.frame) {
            _q.mask = _q.inputs[_q.index].mask;
            _q.index++;
        }
    }
    var _scenario = qa_value(_q.spec, "timingScenario", undefined);
    if (is_struct(_scenario) && qa_value(_scenario, "kind", "") == "platform-interrupt-v1"
        && !_q.interrupt_invoked && _q.frame == qa_value(_scenario, "interruptFrame", -1)) {
        _q.interrupt_invoked = true;
        array_push(_q.events, {kind:"production-platform-interrupt", frame:_q.frame,
            tickId:timing_tick_id(), pausedBefore:global.pause != 0});
        // The actual production callback owns pause, input clearing and saves.
        // This diagnostic is not an OS suspension or an injected pause state.
        platform_interrupt();
    }
}

function qa_player_input() {
    if (!qa_active()) return;
    if (credits_presentation_qa_active()) {
        global.tcc_qa.credits_presentation.invalid = "Unexpected ordinary player input in credits diagnostic";
        return;
    }
    if (object_index == o_playerMU && (!qa_local_multiplayer() || multiplayerplayer != 1)) return;
    var _q = global.tcc_qa;
    if (!_q.running || _q.finished) return;
    if (!timing_is_tick()) return;
    // A campaign exit can create the next room's player before our End Step.
    // Its route decision must not overwrite the completed room's final input.
    if (!is_undefined(_q.goal)) return;
    if (_q.preparing) {
        key_left = false; key_right = false; key_jump = false;
        key_interact = false; key_interact_h = false; key_restart = false;
        return;
    }
    if (!_q.started) {
        _q.started = true;
        _q.start_us = get_timer();
        _q.simulation_us = _q.start_us;
        _q.render_us = _q.start_us;
        _q.initial = qa_snapshot(id);
        // Bounds include this real pre-input pose as well as later observations.
        _q.lowest_y = _q.initial.y; _q.highest_y = _q.initial.y;
        _q.minimum_x = _q.initial.x; _q.maximum_x = _q.initial.x;
    }
    _q.tick_input = true;
    if (_q.recovery_pending) {
        var _world = qa_world_snapshot("player-step-before-input-apply");
        if (!is_undefined(_world)) array_push(_q.events,
            {kind:_q.deaths == 0 ? "initial-world" : "retry-world", state:qa_snapshot(id), world:_world});
        // Some legacy actors are intentionally spawned by their wrapper's first
        // Step. Observe the complete initialized world once ready, without
        // withholding a frame of normal input or moving any actor.
        if (!is_undefined(_world) || !(global.challenges && global.currentchallenge == 19)) _q.recovery_pending = false;
    }
    if (_q.mode == "route" && _q.frame >= qa_value(_q.spec, "routeStartFrame", 0)) _q.mask = qa_route_input(id);
    if (_q.mode == "record" && qa_local_multiplayer()) {
        var _jump = object_index == o_playerMU ? key_jump : input_jump_held;
        var _interact = object_index == o_playerMU ? key_interact : key_interact_h;
        _q.mask = (key_left ? 1 : 0) | (key_right ? 2 : 0) |
            (_jump ? 4 : 0) | (_interact ? 8 : 0) | (key_restart ? 16 : 0) | (_q.mask & 32);
    } else if (_q.mode != "record") {
        if (_q.mode == "route" && (_q.frame == 0 || _q.mask != _q.previous))
            array_push(_q.recorded, {frame:_q.frame, mask:_q.mask});
        var _pressed = _q.mask & ~_q.previous;
        key_left = (_q.mask & 1) != 0;
        key_right = (_q.mask & 2) != 0;
        key_jump = ((object_index == o_playerMU || doublejump == 0 ? _q.mask : _pressed) & 4) != 0;
        key_interact = (_pressed & 8) != 0;
        key_interact_h = (_q.mask & 8) != 0;
        key_restart = (_q.mask & 16) != 0;
    }
}

// Preserve the actual native observation boundary. A player destroyed in
// Step cannot be observed later in End; its death/door callback supplies the
// real terminal pose rather than inventing an End pose or dropping that tick.
function qa_store_player_sample(_state, _phase) {
    var _q = global.tcc_qa;
    if (!_q.started || _q.finished) return;
    if (!is_struct(_state) || _state.frame != _q.frame || !timing_is_tick()
        || !array_contains(["root-end", "death-contact", "exit-contact"], _phase)) {
        _q.invalid = "Invalid player observation phase or simulation tick";
        return;
    }
    // Check every actual observation, even when this tick is not traced.
    // An immediate same-tick replacement must not overwrite the dying actor.
    if (!is_undefined(_q.last) && _q.last.frame == _q.frame) {
        _q.invalid = "Duplicate player observation for one input tick";
        return;
    }
    _state.observationPhase = _phase;
    _q.last = _state;
    _q.lowest_y = min(_q.lowest_y, _state.y);
    _q.highest_y = max(_q.highest_y, _state.y);
    _q.minimum_x = min(_q.minimum_x, _state.x);
    _q.maximum_x = max(_q.maximum_x, _state.x);
    var _stride = max(1, qa_value(_q.spec, "traceEvery", 1));
    if (_q.frame mod _stride == 0) array_push(_q.trace, _state);
}

function qa_observe_death() {
    if (!qa_active() || !global.tcc_qa.running || global.tcc_qa.finished) return;
    if (object_index == o_playerMU && (!qa_local_multiplayer() || multiplayerplayer != 1)) return;
    var _q = global.tcc_qa;
    _q.deaths++;
    var _state = qa_snapshot(id);
    qa_store_player_sample(_state, "death-contact");
    array_push(_q.events, {kind:"death", state:_state});
    var _world = qa_world_snapshot("death-callback-before-destruction");
    if (!is_undefined(_world)) array_push(_q.events, {kind:"death-world", world:_world});
    _q.recovery_pending = true;
}

function qa_observe_exit() {
    if (!qa_active() || !global.tcc_qa.running || global.tcc_qa.finished) return;
    if (object_index == o_playerMU && (!qa_local_multiplayer() || multiplayerplayer != 1)) return;
    var _q = global.tcc_qa;
    if (!is_undefined(_q.goal)) return;
    var _state = qa_snapshot(id);
    if (instance_number(o_key) != 0 || global.cheats || global.noclip || global.easy || global.managablejump || global.visiblethings) {
        _q.invalid = "Exit with keys or assisted rules"; return;
    }
    _q.goal_player_id = id;
    _q.goal = _state;
    qa_store_player_sample(_state, "exit-contact");
    array_push(_q.events, {kind:"exit-contact", state:_state});
}

function qa_end_step() {
    if (!qa_active()) return;
    var _q = global.tcc_qa;
    if (!_q.running || _q.finished || !timing_is_tick()) return;
    if (!sequence_probe_qa_end_ready()) return;
    if (global.cheats || global.noclip || global.easy || global.managablejump || global.visiblethings
        || global.maxfps != TCC_SIM_HZ || global.renderfps != _q.fps) {
        _q.invalid = "Rules or timing domains changed";
    }
    if (_q.invalid != "") { qa_finish("invalid", _q.invalid); return; }
    if (credits_presentation_qa_consume_end()) return;
    var _consumed_tick = _q.started && (is_undefined(_q.goal) || _q.frame <= _q.goal.frame);
    // Opt-in observation of authored troops. This neither creates actors nor
    // changes their AI, position, timers, or ordinary collision rules.
    if (_consumed_tick && qa_value(_q.spec, "observeTroops", false)
        && !variable_struct_exists(_q, "native_actor_targets")) {
        _q.native_actor_targets = []; _q.native_actor_initial = []; _q.native_actor_trace = [];
        for (var _t = 0; _t < instance_number(o_enemyplayer); ++_t) {
            var _troop = instance_find(o_enemyplayer, _t);
            qa_native_actor_register(_troop, "authored-" + string(_t), -1, -1, "ordinary-room");
        }
    }
    if (_consumed_tick) qa_native_actor_observe();
    // Frame indexes are simulation ticks, including ordinary death/respawn
    // ticks. Rendering and the presence of a live player never stop the clock.
    // Completion consumes its actual input tick once. Waiting for the native
    // room transition must not add unconsumed inputs to the recorded clock.
    if (_consumed_tick) {
        if ((_q.tick_input || global.pause != 0 || is_struct(qa_value(_q.spec, "timingScenario", undefined)))
            && is_undefined(_q.goal)) {
            var _player_object = qa_player_object();
            if (instance_exists(_player_object)) {
                var _s = qa_snapshot(instance_find(_player_object, 0));
                if (is_undefined(_q.last) || _s.color != _q.last.color || _s.gravity != _q.last.gravity ||
                    _s.walkSpeed != _q.last.walkSpeed || _s.ammo != _q.last.ammo ||
                    _s.doubleJump != _q.last.doubleJump || _s.keysRemaining != _q.last.keysRemaining ||
                    _s.zeroGravity != _q.last.zeroGravity || _s.water != _q.last.water) {
                    array_push(_q.events, {kind:"state-change", state:_s});
                }
                qa_store_player_sample(_s, "root-end");
            }
        }
        // Storage can reject a same-tick terminal/replacement observation.
        // Surface that error before recording clocks or claiming any status.
        if (_q.invalid != "") { qa_finish("invalid", _q.invalid); return; }
        var _now = get_timer();
        if (_q.mode == "record" && (_q.frame == 0 || _q.mask != _q.previous))
            array_push(_q.recorded, {frame:_q.frame, mask:_q.mask});
        qa_pause_observe();
        array_push(_q.step_costs, _now - _q.step_us);
        array_push(_q.frame_deltas, _now - _q.simulation_us);
        _q.simulation_us = _now;
        _q.previous = _q.mask;
        _q.frame += 1;
        // A valid paused player has no Player Step input by design. Retain
        // the watchdog for an absent player rather than timing out a pause.
        var _paused_player = global.pause != 0 && instance_exists(qa_player_object());
        _q.wait_frames = (_q.tick_input || _paused_player) ? 0 : _q.wait_frames + 1;
    } else _q.wait_frames += 1;
    if (qa_local_multiplayer() && !is_undefined(_q.goal) && !instance_exists(o_playerMU)) {
        qa_finish("observed", "Local race player reached the native door"); return;
    }
    if (!is_undefined(_q.goal)) {
        if (room_get_name(room) != _q.goal.room) {
            qa_finish("complete", "Real exit contact and room transition"); return;
        }
    }
    if (_q.deaths > 0 && !qa_value(_q.spec, "allowDeaths", false)) {
        qa_finish("death", "Player died in the real engine"); return;
    }
    if (_q.wait_frames > TCC_SIM_HZ * 10) { qa_finish("invalid", "No player input for ten seconds"); return; }
    if (is_undefined(_q.goal) && _q.frame >= qa_value(_q.spec, "maxFrames", TCC_SIM_HZ * 180)) {
        qa_finish(qa_value(_q.spec, "expect", "exit") == "frames" ? "observed" : "timeout", "Frame limit reached");
    }
}

function qa_finish(_status, _reason) {
    if (!qa_active() || global.tcc_qa.finished) return;
    var _q = global.tcc_qa;
    _q.finished = true;
    var _practice = qa_value(_q, "practice_observation", undefined);
    if (is_struct(_practice)) {
        _practice.after = qa_practice_progress(_practice.challenge);
        _practice.ending = {room:room_get_name(room), practice:global.levelselect == 1,
            runId:global.challenge_run_id, eligible:scr_challenge_run_eligible(_practice.challenge)};
    }
    var _result = {
        format:"tcc.gameplay-evidence", schemaVersion:1, status:_status, reason:_reason,
        sourceIdentity:qa_value(_q.spec, "identity", undefined),
        fps:_q.fps, seed:_q.seed, frames:_q.frame, deaths:_q.deaths,
        inputClock:TCC_INPUT_CLOCK, simulationHz:TCC_SIM_HZ, simulationFrames:_q.frame, inputMaskVersion:2,
        renderFrames:_q.render_frames, renderFrameDeltasUs:_q.render_frame_deltas,
        initial:_q.initial, final:_q.last, completion:_q.goal, events:_q.events,
        bounds:{minX:_q.minimum_x, maxX:_q.maximum_x, minY:_q.lowest_y, maxY:_q.highest_y},
        elapsedUs:get_timer()-_q.start_us, stepCostsUs:_q.step_costs,
        frameDeltasUs:_q.frame_deltas, trace:_q.trace,
        traceSchemaVersion:2, traceBoundaries:"native-end-or-terminal-contact",
        simulationFrameDeltasUs:_q.frame_deltas, timingProbe:timing_qa_summary(),
        diagnosticPreparation:_q.preparation,
        timingScenario:qa_value(_q.spec, "timingScenario", undefined), pauseObservations:_q.pause_observations,
        cameraObservation:camera_qa_summary(), cameraFollowProbe:camera_follow_qa_summary(),
        sequenceObservation:sequence_qa_summary(), creditsWindblownObservation:credits_windblown_qa_summary(),
        nativeCaptures:_q.captures, nativeCapturesTruncated:_q.captures_truncated,
        troopNavigation:scr_troop_nav_stats(),
        nativeActors:qa_value(_q, "native_actor_trace", []),
        animationDraws:qa_value(_q, "animation_draws", []),
        initialNativeActors:qa_value(_q, "native_actor_initial", []),
        muted:true, drawEventsEnabled:_q.draw_calls > 0, drawCalls:_q.draw_calls,
        inputMode:_q.mode,
        practiceObservation:_practice,
        inputs:_q.mode != "replay" ? _q.recorded : _q.inputs,
        route:qa_value(_q.spec, "route", []), routeIndex:_q.route_index,
        endingContext:{room:room_get_name(room), endlessMode:global.endless ? global.endlessrunmode : 0,
            endlessLevel:global.endlesslevel, challengeTime:global.time, challengeDeaths:global.deaths,
            lives:global.hardmodelives},
        isolatedSaveRoot:_q.save_root,
        normalRules:!global.cheats && !global.noclip && !global.easy && !global.managablejump && !global.visiblethings,
        diagnosticOnly:!is_undefined(_q.initial) && _q.initial.room == "r_gameplay_qa"
    };
    sequence_probe_qa_export(_result);
    credits_presentation_qa_export(_result);
    var _file = file_text_open_write(_q.output);
    file_text_write_string(_file, json_stringify(_result));
    file_text_close(_file);
    show_debug_message("TCC_GAMEPLAY_QA_" + string_upper(_status) + ": " + _reason);
    game_end();
}

function qa_calibration_room() {
    if (!qa_active()) { room_goto(r_mainmenu); return; }
    if (camera_qa_fixture(global.tcc_qa.spec)) return;
    if (is_struct(qa_value(global.tcc_qa.spec, "cameraFollowProbe", undefined)))
        global.tcc_qa.camera_follow_pending_spec = global.tcc_qa.spec;
    if (is_struct(qa_value(global.tcc_qa.spec, "timingProbe", undefined))) {
        global.timing_qa_pending_spec = global.tcc_qa.spec.timingProbe;
        // Let the normal renderer/engine warm before constructing diagnostic
        // assets. These preparation ticks are outside recorded player input.
        global.timing_qa_ready_after_tick = timing_tick_id() + 30;
        global.tcc_qa.preparation = {kind:"native-timing-probe-only", warmupTicks:30,
            roomStartTick:timing_tick_id(), readyAfterTick:global.timing_qa_ready_after_tick,
            startedUs:get_timer(), complete:false};
    }
    if (qa_native_actor_fixture(global.tcc_qa.spec)) return;
    if (qa_slope_fixture(global.tcc_qa.spec)) return;
    // Tall enough to measure the low-gravity pickup even at 150 FPS. These are
    // normal collision objects and a normal player, created with final transforms.
    timing_create_depth(0, 7000, 0, o_whiteblock, {image_xscale:128});
    var _fixture = qa_value(global.tcc_qa.spec, "fixture", "default");
    var _pickups = {gravity01:o_gravity01, gravity05:o_gravity05, gravity15:o_gravity15,
        gravity25:o_gravity25, speed5:o_speed5, speed7:o_speed7, speed10:o_speed10,
        speed15:o_speed15, doublejump:o_doublejumpitem, zerogravity:o_zerogravity,
        zerogravity_cycle:o_zerogravity};
    if (variable_struct_exists(_pickups, _fixture)) {
        // The jump charge must be collected in the air; a ground pickup is
        // consumed by the first jump and never exercises the second jump.
        timing_create_depth(104, _fixture == "doublejump" ? 6864 : 6970,
            0, variable_struct_get(_pickups, _fixture));
    }
    if (_fixture == "water") timing_create_depth(0, 6300, -1, o_water, {image_xscale:128,image_yscale:24});
    if (_fixture == "ice") timing_create_depth(0, 6968, -1, o_iceblock, {image_xscale:128});
    if (_fixture == "ladder") timing_create_depth(96, 6200, -1, o_ladder, {image_yscale:25});
    if (_fixture == "zerogravity_cycle") timing_create_depth(320, 6970, 0, o_gravity15);
    timing_create_depth(96, _fixture == "ice" ? 6940 : 6972, 1, qa_player_object());
    if (qa_value(global.tcc_qa.spec, "animationObservation", false)) {
        // Real custom-drawn objects, away from the player's movement route.
        var _oneways = [o_onewayupblock, o_onewaydownblock, o_onewayleftblock, o_onewayrightblock];
        for (var _w = 0; _w < array_length(_oneways); ++_w)
            timing_create_depth(512 + _w * 64, 6500, 2, _oneways[_w]);
        if (!qa_local_multiplayer()) timing_create_depth(96, 6972, 0, o_gun);
    }
    sequence_qa_setup(global.tcc_qa.spec);
    sequence_probe_qa_setup();
}

// A native-renderer art contact sheet; no gameplay or sprite data is modified.
function qa_draw_art_preview() {
    if (!qa_active() || !qa_value(global.tcc_qa.spec, "artPreview", false)) return;
    var _q = global.tcc_qa;
    if (variable_struct_exists(_q, "art_saved")) return;
    var _target = surface_create(1024, 768);
    if (!surface_exists(_target)) return;
    surface_set_target(_target);
    draw_clear(make_colour_rgb(20, 22, 28));
    draw_set_font(fnt_gamemode); draw_set_halign(fa_left); draw_set_valign(fa_top);
    draw_set_alpha(1); draw_set_colour(c_white);
    draw_text(32, 24, "Slopes - original block materials");
    draw_set_colour(make_colour_rgb(170, 176, 190));
    draw_text(32, 64, "Block    Four slope orientations       Brick material");
    var _normal = [s_redblock,s_yellowblock,s_greenblock,s_blueblock,s_whiteblock];
    var _bricks = [s_redblockbricks,s_yellowblockbricks,s_greenblockbricks,s_blueblockbricks,s_whiteblockbricks];
    for (var _c = 0; _c < 5; ++_c) {
        var _y = 124 + _c * 120;
        draw_sprite_ext(_normal[_c],0,32,_y,2.5,2.5,0,c_white,1);
        for (var _o = 0; _o < 4; ++_o) scr_slope_draw(_c,_o,148 + _o*100,_y,2.5,2.5,1,0);
        draw_sprite_ext(_bricks[_c],0,592,_y,2.5,2.5,0,c_white,1);
        for (var _o = 0; _o < 4; ++_o) scr_slope_draw(_c,_o,708 + _o*72,_y,1.75,1.75,1,1);
    }
    surface_reset_target();
    var _path = qa_value(_q.spec, "artOutput", "");
    if (_path != "") surface_save(_target, _path);
    surface_free(_target);
    _q.art_saved = true;
}

// Observe the presented pose after ordinary input callbacks and Step/End.
// Post-Step traces alone miss a pose reset during a render-only frame.
function qa_animation_draw_observe() {
    if (!qa_active() || !qa_value(global.tcc_qa.spec, "animationObservation", false)) return;
    var _q = global.tcc_qa;
    if (!_q.started || _q.finished) return;
    if (!variable_struct_exists(_q, "animation_draws")) _q.animation_draws = [];
    if (array_length(_q.animation_draws) >= 4096) return;
    var _player_object = qa_player_object();
    if (!instance_exists(_player_object)) return;
    var _p = instance_find(_player_object, 0), _animations = [];
    var _objects = [o_onewayupblock, o_onewaydownblock, o_onewayleftblock,
        o_onewayrightblock, o_timecounter, o_ammocounter];
    for (var _i = 0; _i < array_length(_objects); ++_i) {
        if (!instance_exists(_objects[_i])) continue;
        var _a = instance_find(_objects[_i], 0);
        array_push(_animations, {object:object_get_name(_a.object_index),
            phase:_a.image_index, speed:_a.image_speed,
            tracked:variable_instance_exists(_a, "timing_native")});
    }
    array_push(_q.animation_draws, {tickId:timing_tick_id(), outerId:timing_render_id(),
        tick:timing_is_tick(), frame:_q.frame, paused:global.pause != 0,
        actor:object_get_name(_p.object_index), pose:_p.image_index,
        velocity:_p.animation_vsp, left:_p.key_left, right:_p.key_right,
        animations:_animations});
}

function qa_capture_frames() {
    if (!qa_active()) return;
    var _q = global.tcc_qa;
    var _frames = qa_value(_q.spec, "captureFrames", []);
    if (!is_array(_frames) || !array_contains(_frames, _q.frame) || !surface_exists(application_surface)) return;
    var _directory = qa_value(_q.spec, "captureDirectory", "");
    if (_directory == "") return;
    var _frame = string(_q.frame);
    var _name = "frame-" + string_repeat("0", max(0, 6 - string_length(_frame))) + _frame;
    if (qa_value(_q.spec, "captureClock", "simulation") == "draw") {
        if (array_length(_q.captures) >= 1024) { _q.captures_truncated = true; return; }
        var _t = global.tcc_timing;
        _name += "-generation-" + string(_t.room_generation) + "-draw-" + string(_t.drawn_frames)
            + "-outer-" + string(timing_render_id());
        array_push(_q.captures, {file:_name + ".png", context:"application-surface-at-qa-gui",
            simulationFrame:_q.frame, tickId:timing_tick_id(), outerId:timing_render_id(),
            drawId:_t.drawn_frames, roomGeneration:_t.room_generation,
            room:room_get_name(room), alpha:clamp(_t.accumulator_us * TCC_SIM_HZ / 1000000, 0, 1)});
    }
    surface_save(application_surface, _directory + "/" + _name + ".png");
}

// Exercise the gallery's production renderer with native font/sprite metrics.
// This does not modify the DLC access policy or create a playable completion.
function qa_draw_gallery_preview() {
    if (!qa_active() || !qa_value(global.tcc_qa.spec, "galleryPreview", false)) return;
    var _q = global.tcc_qa;
    if (variable_struct_exists(_q, "gallery_saved")) return;
    var _catalog = commentary_read();
    var _directory = qa_value(_q.spec, "galleryOutput", "");
    if (is_undefined(_catalog) || _directory == "") {
        _q.invalid = "Gallery diagnostic could not load its catalog/output"; return;
    }
    var _surface = surface_create(1024, 768);
    if (!surface_exists(_surface)) return;
    var _pages = [], _issues = [];
    for (var _i = 0; _i < array_length(_catalog.chapters); ++_i) {
        var _chapter = _catalog.chapters[_i], _art = -1;
        if (_chapter.art.kind == "file") {
            _art = sprite_add(level_bundled_path(_chapter.art.path), 1, false, false, 0, 0);
            if (_art < 0) array_push(_issues, _chapter.id + ": image load failed");
        }
        draw_set_font(fnt_mainmenu);
        var _title_width = string_width(_chapter.title) * 0.75;
        draw_set_font(fnt_death);
        var _body_height = string_height_ext(_chapter.body, 24, 608);
        var _caption_height = string_height_ext(_chapter.art.caption, 19, 320);
        if (_title_width > 960 || _body_height > 352 || _caption_height > 110)
            array_push(_issues, _chapter.id + ": text exceeds its reading area");
        for (var _s = 0; _s < array_length(_chapter.sources); ++_s) {
            if (string_height_ext(string(_s+1) + ". " + _chapter.sources[_s].title, 20, 608) > 30
                || string_height_ext(_chapter.sources[_s].note, 19, 588) > 65)
                array_push(_issues, _chapter.id + ": source row overlaps");
        }
        var _prefix = _directory + "/chapter-" + string(_i+1);
        for (var _sources = 0; _sources <= 1; ++_sources) {
            surface_set_target(_surface);
            commentary_draw_page(_catalog, _i, _art, _sources == 1, 0);
            surface_reset_target();
            surface_save(_surface, _prefix + (_sources ? "-sources.png" : ".png"));
        }
        if (_art >= 0 && sprite_exists(_art)) sprite_delete(_art);
        array_push(_pages, {id:_chapter.id, titleWidth:_title_width,
            bodyHeight:_body_height, captionHeight:_caption_height});
    }
    surface_free(_surface);
    var _file = file_text_open_write(_directory + "/render-report.json");
    file_text_write_string(_file, json_stringify({pages:_pages, issues:_issues,
        nativeRenderer:true, entitlementModified:false, sourceIdentity:qa_value(_q.spec,"identity",undefined)}));
    file_text_close(_file);
    _q.gallery_saved = true;
    if (array_length(_issues) > 0) _q.invalid = "Gallery has image or text layout failures";
}

// Authoring assistant: turn inspected route waypoints into ordinary buttons.
// It only returns an input mask and updates the recorder's own cursor. It never
// writes to the player, room, collision objects, pickups, keys, ammo, or physics.
// A route run produces a candidate recording; only its separate replay may
// qualify as completion evidence in tools/gameplay_qa.py.
function qa_route_input(_p) {
    var _q = global.tcc_qa;
    var _route = qa_value(_q.spec, "route", []);
    if (!is_array(_route) || _q.route_index >= array_length(_route)) return 0;
    var _stage = _route[_q.route_index];
    var _action = qa_value(_stage, "action", "");
    var _elapsed = _q.frame - _q.route_frame;
    if (_elapsed > TCC_SIM_HZ * qa_value(_stage, "timeoutSeconds", 20)) {
        _q.invalid = "Route stage " + string(_q.route_index) + " timed out: " + _action;
        return 0;
    }
    var _mask = 0, _done = false;
    var _tx = qa_value(_stage, "x", _p.x);
    var _tolerance = max(0.5, _p.walksp / max(1, _p.inwater) / 2 + 0.05);
    var _at_x = abs(_p.x - _tx) <= _tolerance;
    if (!_at_x) _mask = _p.x < _tx ? 2 : 1;
    var _floor = qa_value(_stage, "floorTop", undefined);
    var _at_floor = is_undefined(_floor) || (abs(_p.bbox_bottom - _floor) <= 1.25 && _p.vsp >= 0 && _p.onGround);
    switch (_action) {
        case "move":
            _done = _at_x && _at_floor;
            break;
        case "jump":
            if (!_q.route_jump) {
                if (_p.onGround) { _mask |= 4; _q.route_jump = true; }
                else _mask = 0;
            } else {
                if (qa_value(_stage, "airJump", false) && !_q.route_airjump
                    && _p.doublejump > 0 && _p.vsp >= qa_value(_stage, "triggerVsp", 0)
                    && (_q.previous & 4) == 0) {
                    _mask |= 4;
                    _q.route_airjump = true;
                }
                _done = _elapsed > 3 && _at_x && _at_floor;
            }
            break;
        case "airjump":
            if (!_q.route_airjump) {
                if (_p.doublejump > 0 && _p.vsp >= qa_value(_stage, "triggerVsp", 0)
                    && (_q.previous & 4) == 0) { _mask |= 4; _q.route_airjump = true; }
            } else _done = _elapsed > 3 && _at_x && _at_floor;
            break;
        case "fire":
            // Ordinary interact presses use the equipped gun's own ammo and
            // firing cooldown. The route controller neither grants nor spends it.
            _mask = (_elapsed mod 2) == 0 ? 8 : 0;
            _done = _elapsed >= ceil(qa_value(_stage, "seconds", 1) * TCC_SIM_HZ);
            break;
        case "climb":
            if (_p.y > qa_value(_stage, "y", _p.y)) _mask |= 4;
            else _done = _at_x;
            break;
        case "interact":
            _mask = (_elapsed mod 2) == 0 ? 8 : 0;
            _done = global.color == qa_value(_stage, "color", -1);
            break;
        case "portal":
            var _target = qa_value(_stage, "target", []);
            if (!is_array(_target) || array_length(_target) != 2) {
                _q.invalid = "Portal route requires an observed destination"; return 0;
            }
            _mask = qa_value(_stage, "direction", 1) > 0 ? 2 : 1;
            _done = abs(_p.x - _target[0]) < 48 && abs(_p.y - _target[1]) < 48;
            break;
        case "wait":
            _mask = qa_value(_stage, "mask", 0);
            _done = _elapsed >= ceil(qa_value(_stage, "seconds", 0.25) * TCC_SIM_HZ);
            break;
        case "wait-hazard":
            // Observe the authored actor's real opening stroke; never advance
            // its timer, move it, or remove it to manufacture a safe passage.
            _mask = 0;
            var _type = asset_get_index(qa_value(_stage, "object", ""));
            if (_type == -1 || asset_get_type(_type) != asset_object
                || !variable_struct_exists(_stage, "startX") || !variable_struct_exists(_stage, "startY")) {
                _q.invalid = "Hazard wait requires an object and authored startX/startY"; return 0;
            }
            var _hazard = noone, _matches = 0;
            for (var _i = 0; _i < instance_number(_type); ++_i) {
                var _candidate = instance_find(_type, _i);
                if (abs(_candidate.xstart - _stage.startX) < 0.1
                    && abs(_candidate.ystart - _stage.startY) < 0.1) {
                    _hazard = _candidate; _matches++;
                }
            }
            if (_matches != 1) {
                _q.invalid = "Hazard wait needs exactly one active authored actor"; return 0;
            }
            _done = _hazard.x >= qa_value(_stage, "minX", -infinity)
                && _hazard.x <= qa_value(_stage, "maxX", infinity)
                && _hazard.y >= qa_value(_stage, "minY", -infinity)
                && _hazard.y <= qa_value(_stage, "maxY", infinity);
            if (variable_struct_exists(_stage, "change")) {
                if (!variable_instance_exists(_hazard, "change")) {
                    _q.invalid = "Hazard wait actor has no change state"; return 0;
                }
                _done = _done && _hazard.change == _stage.change;
            }
            break;
        case "restart":
            // The normal restart input invokes the normal death/retry lifecycle.
            // Replay ticks continue while dead; route decisions resume on live input.
            if (_q.deaths == _q.route_deaths) _mask = 16;
            else { _mask = 0; _done = true; }
            break;
        default:
            _q.invalid = "Unknown route action: " + _action;
    }
    if (_done) {
        array_push(_q.events, {kind:"route-waypoint", index:_q.route_index, state:qa_snapshot(_p)});
        _q.route_index++;
        _q.route_frame = _q.frame + 1;
        _q.route_jump = false;
        _q.route_airjump = false;
        _q.route_deaths = _q.deaths;
        return 0;
    }
    return _mask;
}

// Runtime observations only. Lunar uses its initialized authored world and
// generated projectiles; ordinary campaign playback requires no injected scope.
function qa_world_snapshot(_native_phase = undefined) {
    return qa_lunar_world_snapshot(_native_phase);
}
