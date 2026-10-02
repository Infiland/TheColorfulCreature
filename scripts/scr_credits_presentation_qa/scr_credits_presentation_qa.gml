/// Opt-in credits presentation diagnostic. No player or completion is invented.
/// Begin/End calls belong to real central native boundaries, not event emulation.
function credits_presentation_qa_active() {
    return TCC_GAMEPLAY_QA && qa_active()
        && is_struct(qa_value(global.tcc_qa, "credits_presentation", undefined));
}
function credits_presentation_qa_clock_started() {
    return credits_presentation_qa_active() && global.tcc_qa.credits_presentation.started;
}
function credits_presentation_qa_validate(_spec) {
    var _option = qa_value(_spec, "creditsPresentationDiagnostic", undefined);
    var _fx = qa_value(_spec, "creditsWindblownObservation", undefined);
    if (is_undefined(_option) && is_undefined(_fx)) return {valid:true, error:""};
    try {
        if (!is_struct(_option) || qa_value(_option, "kind", "") != "normal-entry-logical-clock-v1"
            || qa_value(_option, "entryRoom", "") != "r_support"
            || qa_value(_option, "diagnosticOnly", undefined) != true
            || !is_bool(_option.diagnosticOnly)
            || qa_value(_option, "ordinaryInputProof", undefined) != false
            || !is_bool(_option.ordinaryInputProof)) throw "Credits requires explicit presentation-only opt-in";
        if (qa_value(_spec, "room", "") != "r_credits" || qa_value(_spec, "mode", "") != "replay"
            || qa_value(_spec, "expect", "") != "frames"
            || !is_array(qa_value(_spec, "inputs", undefined)) || array_length(_spec.inputs) != 0
            || !credits_windblown_integer(qa_value(_spec, "maxFrames", undefined), 120, 7200))
            throw "Credits requires bounded no-player frames with empty ordinary inputs";
        var _conflicts = ["actor", "fixture", "timingProbe", "timingScenario", "cameraFixture", "cameraFollowProbe",
            "sequenceObservation", "sequenceClockProbe", "actorFixture", "slopeFixture", "challenge", "specialIndex",
            "levelSelect"];
        for (var _i = 0; _i < array_length(_conflicts); ++_i)
            if (variable_struct_exists(_spec, _conflicts[_i])) throw "Credits has conflicting fixture/lifecycle option";
        if (!is_struct(_fx) || qa_value(_fx, "kind", "") != "credits-native-v1"
            || !is_bool(qa_value(_fx, "enabled", undefined))
            || !credits_windblown_integer(qa_value(_fx, "privateSeed", undefined), 1, 2147483646)
            || !credits_windblown_integer(qa_value(_fx, "firstTicks", undefined), 0, 240)
            || !credits_windblown_integer(qa_value(_fx, "traceEveryTicks", undefined), 1, 120)
            || !credits_windblown_integer(qa_value(_fx, "maxSamples", undefined), 128, 12000))
            throw "Credits requires typed bounded native model observation";
        var _lifecycle = qa_value(_spec, "creditsWindblownLifecycle", undefined);
        if (!is_undefined(_lifecycle)) {
            if (!is_struct(_lifecycle) || _spec.maxFrames < 600
                || !is_struct(qa_value(_lifecycle, "atDiagnosticTick240", undefined))
                || !is_struct(qa_value(_lifecycle, "atDiagnosticTick480", undefined))
                || qa_value(_lifecycle.atDiagnosticTick240, "action", "") != "room_restart"
                || qa_value(_lifecycle.atDiagnosticTick480, "action", "") != "leave-and-reenter"
                || qa_value(_lifecycle.atDiagnosticTick480, "viaRoom", "") != "r_mainmenu"
                || qa_value(_lifecycle.atDiagnosticTick480, "nextRoom", "") != "r_credits")
                throw "Credits lifecycle requires the exact bounded normal-routing scenario";
            if (array_length(variable_struct_get_names(_lifecycle)) != 2
                || array_length(variable_struct_get_names(_lifecycle.atDiagnosticTick240)) != 1
                || array_length(variable_struct_get_names(_lifecycle.atDiagnosticTick480)) != 3)
                throw "Credits lifecycle contains unsupported actions";
        }
        var _rng = qa_value(_spec, "creditsWindblownRngSentinels", undefined);
        if (!is_undefined(_rng)) {
            if (!is_struct(_rng) || qa_value(_rng, "kind", "") != "diagnostic-only-native-gameplay-rng"
                || qa_value(_rng, "callsPerTick", undefined) != 3 || !is_real(_rng.callsPerTick) || is_bool(_rng.callsPerTick)
                || qa_value(_rng, "sameCallsInPairedControl", undefined) != true || !is_bool(_rng.sameCallsInPairedControl)
                || !is_array(qa_value(_rng, "ticks", undefined)) || array_length(_rng.ticks) > 16)
                throw "Credits RNG sentinel schema is invalid";
            var _last = 0;
            for (var _r = 0; _r < array_length(_rng.ticks); ++_r) {
                var _tick = _rng.ticks[_r];
                if (!credits_windblown_integer(_tick, 1, _spec.maxFrames) || _tick <= _last)
                    throw "Credits RNG sentinel ticks must be ordered, unique and in range";
                _last = _tick;
            }
        }
        return {valid:true, error:""};
    } catch (_error) { return {valid:false, error:credits_windblown_error(_error)}; }
}
function credits_presentation_qa_stamp(_phase) {
    var _t = global.tcc_timing, _d = global.tcc_qa.credits_presentation;
    return {phase:_phase, room:room_get_name(room), roomGeneration:_t.room_generation,
        outerId:timing_render_id(), tickId:timing_tick_id(), isTick:timing_is_tick(),
        diagnosticTicks:_d.completed_ticks, playerQaStarted:global.tcc_qa.started,
        paused:global.pause != 0, beginPending:_t.begin_pending,
        endObserved:_t.ended_render == timing_render_id(), nativeHz:game_get_speed(gamespeed_fps),
        renderCap:global.renderfps, generatedDrawFrames:_t.drawn_frames,
        nativeEventType:event_type, nativeEventNumber:event_number};
}
function credits_presentation_qa_launch() {
    if (!TCC_GAMEPLAY_QA || !qa_active()
        || is_undefined(qa_value(global.tcc_qa.spec, "creditsPresentationDiagnostic", undefined))) return false;
    var _q = global.tcc_qa;
    _q.credits_presentation = {schemaVersion:1, fixture:"credits-presentation-clock-v1", invalid:"",
        stage:"support-entry", started:false, completed_ticks:0, complete_pairs:0,
        begin_outer:-1, begin_generation:-1, begin_tick:-1, begin_room:noone, begin_us:0,
        last_begin_outer:-1, last_end_outer:-1, last_consumed_outer:-1, last_qa_end_outer:-1,
        start_us:0, start_tick:undefined, start_outer:undefined, start_generation:undefined,
        current_generation:undefined, transition_old_generation:undefined, room_end_seen:false,
        transition_wait_ticks:0, lifecycle:[], lifecycle_truncated:false, entries:[],
        entry:undefined, staging_ticks:0, skipped_outers:0, partial_ends:0,
        duplicate_begins:0, duplicate_ends:0, clock_samples:[], samples_truncated:false, sample_this_outer:false,
        sentinels:[], rng_index:0, final:undefined};
    // The real eligible menu is entered first. Its next complete native Begin
    // invokes exactly the shared production action used by the actual button.
    room_goto(r_support);
    return true;
}
function credits_presentation_qa_sample(_phase) {
    var _d = global.tcc_qa.credits_presentation;
    if (!_d.sample_this_outer) return;
    if (array_length(_d.clock_samples) >= 2048) { _d.samples_truncated = true; return; }
    array_push(_d.clock_samples, credits_presentation_qa_stamp(_phase));
}
function credits_presentation_qa_begin() {
    if (!credits_presentation_qa_active() || global.tcc_qa.finished) return;
    var _q = global.tcc_qa, _d = _q.credits_presentation, _t = global.tcc_timing;
    if (_d.last_begin_outer == timing_render_id()) { _d.duplicate_begins += 1; return; }
    _d.last_begin_outer = timing_render_id();
    _d.sample_this_outer = _d.completed_ticks < 24 || (_d.completed_ticks + 1) mod 60 == 0;
    _d.begin_outer = timing_render_id(); _d.begin_tick = timing_tick_id();
    _d.begin_generation = _t.room_generation; _d.begin_room = room; _d.begin_us = get_timer();
    if (_t.begin_pending) { _d.invalid = "Credits Begin hook ran outside admitted native Begin"; return; }
    if (!timing_is_tick()) { _d.skipped_outers += 1; credits_presentation_qa_sample("root-begin"); return; }
    if (_d.started && _d.stage != "observing") {
        credits_presentation_qa_transition_begin();
        if (_d.stage != "observing" || _d.invalid != "") return;
    }
    if (!_d.started) {
        _d.staging_ticks += 1;
        if (_d.staging_ticks > 600) { _d.invalid = "Credits normal-entry staging exceeded ten logical seconds"; return; }
        if (_d.stage == "support-entry" && room == r_support) {
            _d.entry = {before:credits_presentation_qa_stamp("normal-entry-before"),
                hardmodeUnlockBefore:global.hardmodeunlock,
                originBefore:{x:sprite_get_xoffset(s_playerred), y:sprite_get_yoffset(s_playerred)}};
            var _entered = credits_entry_action();
            _d.entry.entered = _entered;
            _d.entry.after = credits_presentation_qa_stamp("normal-entry-after");
            _d.entry.hardmodeUnlockAfter = global.hardmodeunlock;
            _d.entry.originAfter = {x:sprite_get_xoffset(s_playerred), y:sprite_get_yoffset(s_playerred)};
            array_push(_d.entries, _d.entry);
            if (!_entered) _d.invalid = "Credits normal shared entry action was blocked";
            else _d.stage = "credits-entry";
            return;
        }
        if (_d.stage != "credits-entry" || room != r_credits) return;
        if (!credits_windblown_active()) { _d.invalid = "Credits owned native model did not become ready"; return; }
        if (sprite_get_xoffset(s_playerred) != 16 || sprite_get_yoffset(s_playerred) != 16) {
            _d.invalid = "Credits actual shared-entry sprite origin was not retained"; return;
        }
        _d.started = true; _d.stage = "observing";
        _d.start_us = get_timer(); _d.start_tick = timing_tick_id();
        _d.start_outer = timing_render_id(); _d.start_generation = _t.room_generation;
        _d.current_generation = _t.room_generation;
        // Only render timing is initialized. Player start/snapshots/bounds and
        // ordinary input proof state remain untouched and honestly undefined.
        _q.render_us = _d.start_us; _q.simulation_us = _d.start_us;
    }
    if (room != r_credits || _t.room_generation != _d.current_generation || global.pause != 0
        || instance_exists(o_player) || instance_exists(o_playerMU) || _q.started
        || !is_undefined(_q.initial) || !is_undefined(_q.goal) || !credits_windblown_active()) {
        _d.invalid = "Credits basic diagnostic changed room/pause/player/completion context"; return;
    }
    var _rng = qa_value(_q.spec, "creditsWindblownRngSentinels", undefined);
    var _next_tick = _d.completed_ticks + 1;
    if (is_struct(_rng) && _d.rng_index < array_length(_rng.ticks)
        && _rng.ticks[_d.rng_index] == _next_tick) {
        var _sample = {stamp:credits_presentation_qa_stamp("rng-before-model"),
            diagnosticTick:_next_tick, seedReadBefore:random_get_seed(), values:[]};
        // Exactly the same three genuine native calls in the on/off pair.
        // Reading random_get_seed alone is not proof of full native RNG state.
        for (var _i = 0; _i < 3; ++_i) array_push(_sample.values, random(1));
        _sample.seedReadAfter = random_get_seed();
        array_push(_d.sentinels, _sample); _d.rng_index += 1;
    }
    credits_presentation_qa_sample("root-begin");
}
function credits_presentation_qa_end() {
    if (!credits_presentation_qa_active() || global.tcc_qa.finished) return;
    var _q = global.tcc_qa, _d = _q.credits_presentation, _t = global.tcc_timing;
    if (_d.last_end_outer == timing_render_id()) { _d.duplicate_ends += 1; return; }
    _d.last_end_outer = timing_render_id();
    var _paired = _d.begin_outer == timing_render_id() && _d.begin_generation == _t.room_generation
        && _d.begin_room == room && _d.begin_tick == timing_tick_id()
        && !_t.begin_pending && _t.ended_render == timing_render_id();
    if (!_paired) { _d.partial_ends += 1; return; }
    if (!_d.started || !timing_is_tick() || _d.stage != "observing" || _d.invalid != "") return;
    if (room != r_credits || _t.room_generation != _d.current_generation) {
        _d.invalid = "Credits basic diagnostic ended in a different room generation"; return;
    }
    _d.complete_pairs += 1; _d.completed_ticks += 1;
    _d.last_consumed_outer = timing_render_id();
    _q.frame = _d.completed_ticks;
    var _now = get_timer();
    array_push(_q.frame_deltas, _now - _q.simulation_us); _q.simulation_us = _now;
    array_push(_q.step_costs, _now - _d.begin_us);
    credits_presentation_qa_sample("root-end");
    _d.final = credits_presentation_qa_stamp("last-complete-end");
    if (is_struct(qa_value(_q.spec, "creditsWindblownLifecycle", undefined))) {
        if (_d.completed_ticks == 240) {
            _d.stage = "restart-pending"; _d.room_end_seen = false;
            _d.transition_old_generation = _t.room_generation; _d.transition_wait_ticks = 0;
            credits_presentation_qa_lifecycle("normal-room-restart-request");
            room_restart();
        } else if (_d.completed_ticks == 480) {
            _d.stage = "mainmenu-entry"; _d.room_end_seen = false;
            _d.transition_old_generation = _t.room_generation; _d.transition_wait_ticks = 0;
            credits_presentation_qa_lifecycle("normal-credits-back-request");
            scr_back();
        }
    }
}
// Called by normal qa_end_step after its unchanged rules validation. Suppress
// the ordinary absent-player watchdog only for this explicit diagnostic.
function credits_presentation_qa_consume_end() {
    if (!credits_presentation_qa_active()) return false;
    var _q = global.tcc_qa, _d = _q.credits_presentation;
    if (_d.invalid != "") { qa_finish("invalid", _d.invalid); return true; }
    if (_d.last_qa_end_outer == timing_render_id()) return true;
    _d.last_qa_end_outer = timing_render_id();
    if (_d.last_consumed_outer != timing_render_id()) return true;
    if (_d.completed_ticks >= _q.spec.maxFrames) {
        qa_finish("observed", "Bounded native credits presentation ticks observed; diagnostic only");
    }
    return true;
}
function credits_presentation_qa_summary() {
    if (!credits_presentation_qa_active()) return undefined;
    var _d = global.tcc_qa.credits_presentation;
    return {schemaVersion:1, fixture:_d.fixture, verdict:"unassessed", invalid:_d.invalid,
        diagnosticOnly:true, ordinaryInputProof:false, clockDomain:"presentation-logical-60",
        entry:_d.entry, entries:_d.entries, lifecycle:_d.lifecycle,
        lifecycleTruncated:_d.lifecycle_truncated, lifecycleStage:_d.stage,
        currentGeneration:_d.current_generation, transitionWaitTicks:_d.transition_wait_ticks,
        started:_d.started, completedTicks:_d.completed_ticks, completePairs:_d.complete_pairs,
        startTick:_d.start_tick, startOuter:_d.start_outer, startGeneration:_d.start_generation,
        stagingTicks:_d.staging_ticks, skippedOuters:_d.skipped_outers, partialEnds:_d.partial_ends,
        duplicateBegins:_d.duplicate_begins, duplicateEnds:_d.duplicate_ends,
        clockSamples:_d.clock_samples, samplesTruncated:_d.samples_truncated,
        sentinels:_d.sentinels, sentinelsInvoked:_d.rng_index, final:_d.final};
}
function credits_presentation_qa_export(_result) {
    if (!credits_presentation_qa_active()) return;
    var _d = global.tcc_qa.credits_presentation;
    _result.diagnosticOnly = true; _result.ordinaryInputProof = false;
    _result.clockDomain = "presentation-logical-60";
    _result.creditsPresentationDiagnostic = credits_presentation_qa_summary();
    if (is_undefined(global.tcc_qa.initial) && is_undefined(global.tcc_qa.last)) _result.bounds = undefined;
    // Preserve any unexpected real player/completion evidence on invalid runs.
    // Valid no-player initial/final/completion are already undefined in qa_finish.
    _result.elapsedUs = _d.started ? get_timer() - _d.start_us : undefined;
}

// These hooks are called only from genuine native Room End / logical Begin.
function credits_presentation_qa_lifecycle(_action) {
    var _d = global.tcc_qa.credits_presentation;
    if (array_length(_d.lifecycle) >= 32) { _d.lifecycle_truncated = true; return; }
    array_push(_d.lifecycle, {action:_action, stamp:credits_presentation_qa_stamp("lifecycle"),
        stage:_d.stage, model:credits_windblown_active()
            ? credits_windblown_qa_snapshot(global.tcc_credits_windblown_state) : undefined});
}
function credits_presentation_qa_room_end() {
    if (!credits_presentation_qa_active() || global.tcc_qa.finished) return;
    var _d = global.tcc_qa.credits_presentation;
    credits_presentation_qa_lifecycle("native-room-end");
    if (_d.started && _d.stage == "observing") {
        _d.invalid = "Credits encountered an unrequested native room exit";
        return;
    }
    _d.room_end_seen = true;
}
function credits_presentation_qa_transition_begin() {
    var _d = global.tcc_qa.credits_presentation, _t = global.tcc_timing;
    _d.transition_wait_ticks += 1;
    if (_d.transition_wait_ticks > 600) { _d.invalid = "Credits lifecycle staging exceeded ten logical seconds"; return; }
    if (_d.stage == "mainmenu-entry" && room == r_mainmenu) {
        if (!_d.room_end_seen || _t.room_generation == _d.transition_old_generation) {
            _d.invalid = "Credits leave did not observe a real Room End/Start"; return;
        }
        credits_presentation_qa_lifecycle("normal-support-entry-request");
        if (!support_entry_action()) { _d.invalid = "Normal support reentry was blocked"; return; }
        _d.stage = "support-reentry";
        return;
    }
    if (_d.stage == "support-reentry" && room == r_support) {
        var _entry = {before:credits_presentation_qa_stamp("normal-reentry-before"),
            hardmodeUnlockBefore:global.hardmodeunlock,
            originBefore:{x:sprite_get_xoffset(s_playerred), y:sprite_get_yoffset(s_playerred)}};
        _entry.entered = credits_entry_action();
        _entry.after = credits_presentation_qa_stamp("normal-reentry-after");
        _entry.hardmodeUnlockAfter = global.hardmodeunlock;
        _entry.originAfter = {x:sprite_get_xoffset(s_playerred), y:sprite_get_yoffset(s_playerred)};
        array_push(_d.entries, _entry);
        if (!_entry.entered) { _d.invalid = "Normal credits reentry was blocked"; return; }
        _d.stage = "credits-reentry";
        return;
    }
    if ((_d.stage == "restart-pending" || _d.stage == "credits-reentry") && room == r_credits) {
        // A restart can remain in the same room ID while native teardown is
        // still pending. Never treat that old generation as a fresh arrival.
        if (_t.room_generation == _d.transition_old_generation) return;
        if (!_d.room_end_seen || !credits_windblown_active()) {
            _d.invalid = "Credits lifecycle did not observe native teardown and a ready new model"; return;
        }
        if (global.tcc_credits_windblown_state.generation != _t.room_generation
            || sprite_get_xoffset(s_playerred) != 16 || sprite_get_yoffset(s_playerred) != 16) {
            _d.invalid = "Credits new native setup generation/origin mismatch"; return;
        }
        _d.current_generation = _t.room_generation;
        credits_presentation_qa_lifecycle("native-new-credits-complete-begin");
        _d.stage = "observing"; _d.transition_wait_ticks = 0;
        // The production constructor reset its private state on actual entry.
        // The adapter does not reset native or private RNG to manufacture it.
    }
}
