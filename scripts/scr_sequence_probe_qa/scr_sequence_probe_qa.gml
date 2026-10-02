/// Optional native sequence stimuli, not a playable-room/input completion proof.
/// Actual public APIs and native phase hooks only. No head seeks/event dispatch.
function sequence_probe_qa_active() {
    return TCC_GAMEPLAY_QA && qa_active()
        && is_struct(qa_value(global.tcc_qa, "sequence_probe", undefined));
}
function sequence_probe_qa_validate(_spec) {
    var _p = qa_value(_spec, "sequenceClockProbe", undefined);
    if (is_undefined(_p)) return {valid:true, error:""};
    try {
        if (!is_struct(_p) || !is_struct(qa_value(_spec, "sequenceObservation", undefined))
            || _spec.sequenceObservation.kind != "magentaswing-v1"
            || qa_value(_spec.sequenceObservation, "observeStep", undefined) != true
            || !is_bool(_spec.sequenceObservation.observeStep)
            || qa_value(_spec, "room", "") != "r_gameplay_qa" || qa_value(_spec, "fixture", "") != "default"
            || qa_value(_spec, "actor", "") != "single-player" || qa_value(_spec, "mode", "") != "replay"
            || qa_value(_spec, "expect", "") != "frames"
            || !credits_windblown_integer(qa_value(_spec, "maxFrames", undefined), 248, 480))
            throw "Sequence probe requires intact bounded ordinary SP calibration";
        var _conflicts = ["timingProbe", "timingScenario", "cameraFixture", "cameraFollowProbe", "actorFixture",
            "slopeFixture", "challenge", "specialIndex", "levelSelect", "creditsPresentationDiagnostic"];
        for (var _i = 0; _i < array_length(_conflicts); ++_i)
            if (variable_struct_exists(_spec, _conflicts[_i])) throw "Conflicting sequence probe context";
        if (!is_bool(qa_value(_p, "nativeHeadWrites", undefined)) || _p.nativeHeadWrites != false
            || !is_bool(qa_value(_p, "manualEventDispatch", undefined)) || _p.manualEventDispatch != false)
            throw "Sequence probe must forbid synthetic native evaluation";
        var _kind = qa_value(_p, "kind", "");
        if (_kind == "native-public-intent-v1") {
            if (!is_array(qa_value(_p, "actions", undefined)) || array_length(_p.actions) > 16)
                throw "Sequence intent actions must be bounded";
            var _last = 0;
            for (var _a = 0; _a < array_length(_p.actions); ++_a) {
                var _action = _p.actions[_a];
                if (!is_struct(_action) || !credits_windblown_integer(qa_value(_action, "tick", undefined), 1, _spec.maxFrames)
                    || _action.tick <= _last || !array_contains(["timing_sequence_speedscale", "timing_sequence_play", "timing_sequence_pause"], qa_value(_action, "api", "")))
                    throw "Invalid ordered sequence intent action";
                if (_action.api == "timing_sequence_speedscale") {
                    if (!timing_sequence_finite(qa_value(_action, "value", undefined)) || abs(_action.value) > 4)
                        throw "Invalid bounded sequence intent scale";
                } else if (variable_struct_exists(_action, "value")) throw "Play/Pause must not contain a scale";
                _last = _action.tick;
            }
        } else if (_kind == "native-late-birth-v1") {
            if (!credits_windblown_integer(qa_value(_p, "createOnFirstSkippedOuterAfterTick", undefined), 1, 120)
                || qa_value(_p, "phase", "") != "root-step"
                || !timing_sequence_finite(qa_value(_p, "callerFinalSpeedscale", undefined)) || _p.callerFinalSpeedscale != 0
                || qa_value(_p, "playThenScaleZero", undefined) != true || !is_bool(_p.playThenScaleZero)
                || !credits_windblown_integer(qa_value(_p, "setScaleOneAtTick", undefined), 1, _spec.maxFrames)
                || _p.setScaleOneAtTick <= _p.createOnFirstSkippedOuterAfterTick
                || qa_value(_p, "untriggeredProbeMayPass", undefined) != false || !is_bool(_p.untriggeredProbeMayPass))
                throw "Invalid native late-birth scenario";
        } else if (_kind == "native-public-frame-type-v1") {
            if (qa_value(_p, "graphicUnavailableExpected", undefined) != true || !is_bool(_p.graphicUnavailableExpected)
                || qa_value(_p, "compareNativeHeadOnly", undefined) != true || !is_bool(_p.compareNativeHeadOnly))
                throw "Frame-type probe must declare an empty native head-only asset";
        } else if (_kind == "native-production-pause-lifecycle-v1") {
            if (_spec.maxFrames < 360 || qa_value(_p, "requireNormalPauseDispatch", undefined) != true
                || !is_bool(_p.requireNormalPauseDispatch) || qa_value(_p, "restartAfterObservedPauseResume", undefined) != true
                || !is_bool(_p.restartAfterObservedPauseResume) || qa_value(_p, "nativeLifecycle", undefined) != true
                || !is_bool(_p.nativeLifecycle) || qa_value(_p, "initialPartialMustBeHeld", undefined) != true
                || !is_bool(_p.initialPartialMustBeHeld) || qa_value(_p, "recreateDefaultCalibrationByRealRoomRestart", undefined) != true
                || !is_bool(_p.recreateDefaultCalibrationByRealRoomRestart))
                throw "Invalid normal pause/restart sequence scenario";
        } else throw "Unknown native sequence probe kind";
        return {valid:true, error:""};
    } catch (_error) { return {valid:false, error:sequence_qa_error(_error)}; }
}
function sequence_probe_qa_allow_setup() {
    if (!sequence_probe_qa_active()) return false;
    var _d = global.tcc_qa.sequence_probe;
    // This allowance is narrow: native Room End archived the old observation;
    // real calibration Room Creation is now rebuilding its normal floor/player.
    return _d.kind == "native-production-pause-lifecycle-v1" && _d.stage == "restart-entry"
        && _d.room_end_seen && _d.restart_queued && room == r_gameplay_qa;
}
function sequence_probe_qa_stamp(_phase, _draw_context = false) {
    var _d = global.tcc_qa.sequence_probe, _t = global.tcc_timing;
    return {phase:_phase, room:room_get_name(room), roomGeneration:_t.room_generation,
        outerId:timing_render_id(), tickId:timing_tick_id(), isTick:timing_is_tick(),
        probeTicks:_d.completed_ticks, simulationFrame:global.tcc_qa.frame,
        playerStarted:global.tcc_qa.started, paused:global.pause != 0,
        inputMask:global.tcc_qa.mask, previousInputMask:global.tcc_qa.previous,
        pauseControllerPresentNative:instance_exists(o_pausesystem), pauseScreenPresentNative:instance_exists(o_pausescreen),
        beginPending:_t.begin_pending, rootEndObserved:_t.ended_render == timing_render_id(),
        generatedDrawFrames:_t.drawn_frames, drawScheduled:_t.draw_frame,
        nativeHz:game_get_speed(gamespeed_fps), renderCap:global.renderfps,
        drawContext:_draw_context, viewIndex:_draw_context ? view_current : undefined,
        nativeEventType:event_type, nativeEventNumber:event_number};
}
function sequence_probe_qa_element_state(_e) {
    var _state = {label:_e.label, layerRef:_e.layer, elementRef:_e.element,
        ownerGeneration:_e.generation, graphicExpected:_e.graphic_expected,
        readSucceeded:false, graphic:{available:false, queried:false}};
    try {
        _state.ownerGenerationMatches = _e.generation == global.tcc_timing.room_generation;
        // Setup precedes native Room Start generation admission. It is raw,
        // not recorded acceptance; its first complete Begin adopts generation.
        if (!_state.ownerGenerationMatches) return _state;
        _state.layerPresentNative = layer_exists(_e.layer);
        _state.elementPresenceQueried = _state.layerPresentNative != 0;
        _state.elementPresentNative = _state.elementPresenceQueried ? layer_sequence_exists(_e.layer, _e.element) : false;
        if (_state.elementPresentNative == 0) return _state;
        var _asset = layer_sequence_get_sequence(_e.element);
        _state.assetName = _asset.name; _state.length = _asset.length; _state.loopMode = _asset.loopmode;
        _state.playbackSpeed = _asset.playbackSpeed; _state.playbackSpeedType = _asset.playbackSpeedType;
        _state.head = layer_sequence_get_headpos(_e.element); _state.direction = layer_sequence_get_headdir(_e.element);
        _state.nativeScale = layer_sequence_get_speedscale(_e.element); _state.clock = timing_sequence_state(_e.element);
        _state.pausedNative = layer_sequence_is_paused(_e.element); _state.finishedNative = layer_sequence_is_finished(_e.element);
        _state.pose = {x:layer_sequence_get_x(_e.element), y:layer_sequence_get_y(_e.element),
            angle:layer_sequence_get_angle(_e.element), xscale:layer_sequence_get_xscale(_e.element), yscale:layer_sequence_get_yscale(_e.element)};
        _state.readSucceeded = true;
        if (_e.graphic_expected) {
            _state.graphic.queried = true;
            try {
                var _instance = layer_sequence_get_instance(_e.element);
                var _track = _instance.activeTracks[0];
                if (!is_undefined(_track)) _state.graphic = {available:true, queried:true, spriteRef:_track.spriteIndex,
                    x:_track.posx, y:_track.posy, rotation:_track.rotation, xorigin:_track.xorigin, yorigin:_track.yorigin,
                    xscale:_track.scalex, yscale:_track.scaley, imageIndex:_track.imageindex, imageSpeed:_track.imagespeed};
            } catch (_graphic_error) { _state.graphic.readError = sequence_qa_error(_graphic_error); }
        }
    } catch (_error) { _state.readError = sequence_qa_error(_error); }
    return _state;
}
function sequence_probe_qa_log(_action, _element = undefined) {
    var _d = global.tcc_qa.sequence_probe;
    if (array_length(_d.actions) >= 32) { _d.actions_truncated = true; return; }
    array_push(_d.actions, {action:_action, stamp:sequence_probe_qa_stamp("native-action"),
        state:is_undefined(_element) ? undefined : sequence_probe_qa_element_state(_element)});
}
function sequence_probe_qa_setup() {
    if (!TCC_GAMEPLAY_QA || !qa_active()
        || is_undefined(qa_value(global.tcc_qa.spec, "sequenceClockProbe", undefined))) return;
    var _q = global.tcc_qa;
    if (!sequence_probe_qa_active()) _q.sequence_probe = {schemaVersion:1, fixture:"native-sequence-probe-v1",
        spec:_q.spec.sequenceClockProbe, kind:_q.spec.sequenceClockProbe.kind, invalid:"", stage:"observing",
        started:false, completed_ticks:0, begin_outer:-1, begin_generation:-1, begin_tick:-1,
        last_begin_outer:-1, last_end_outer:-1, last_paired_end:-1, current_generation:undefined,
        duplicate_begins:0, duplicate_ends:0, partial_ends:0, action_index:0, actions:[], actions_truncated:false,
        samples:[], preparation_samples:[], preparation_truncated:false, phase_counts:{}, samples_truncated:false, dropped_samples:0,
        extras:[], frame_asset:undefined, retired_frame_assets:[], assets_destroyed:0,
        late_created:false, late_scale_applied:false, late_scale_tick_missed:false,
        pause_seen:false, resume_seen:false, pause_ticks:0, restart_queued:false,
        room_end_seen:false, restart_old_generation:undefined, restart_arrived:false,
        lifecycle:[], sequence_segments:[], setup_entries:[]};
    var _d = _q.sequence_probe;
    try {
        if (!sequence_qa_active()) throw "Sequence probe lacks a valid untouched native main observation";
        if (array_length(_d.setup_entries) >= 2) throw "Sequence probe exceeds two real calibration entries";
        array_push(_d.setup_entries, {room:room_get_name(room), tick:timing_tick_id(), outer:timing_render_id(),
            generationBeforeRoomStart:global.tcc_timing.room_generation,
            calibration:_q.sequence_observation.calibration, primarySetup:_q.sequence_observation.setup});
        if (_d.kind == "native-public-frame-type-v1") {
            // New public native asset only. Never mutate seq_magentaswing or
            // its shared track/callback data. Sequence engine performs motion.
            _d.frame_asset = sequence_create();
            _d.frame_asset.length = 120; _d.frame_asset.loopmode = seqplay_loop;
            _d.frame_asset.playbackSpeed = 1;
            _d.frame_asset.playbackSpeedType = spritespeed_framespergameframe;
            var _layer = layer_create(-191, "TCC_SequenceQA_FrameType");
            var _element = timing_sequence_create(_layer, 480, 6720, _d.frame_asset);
            var _e = {label:"frame-type-native", layer:_layer, element:_element,
                generation:global.tcc_timing.room_generation, graphic_expected:false, pending_entry:true};
            array_push(_d.extras, _e); timing_sequence_play(_element);
            sequence_probe_qa_log("public-frame-asset-create-play", _e);
        }
    } catch (_error) { _d.invalid = sequence_qa_error(_error); }
}
function sequence_probe_qa_begin() {
    if (!sequence_probe_qa_active() || global.tcc_qa.finished) return;
    var _q = global.tcc_qa, _d = _q.sequence_probe, _t = global.tcc_timing;
    if (_d.last_begin_outer == timing_render_id()) { _d.duplicate_begins += 1; return; }
    _d.last_begin_outer = timing_render_id(); _d.begin_outer = timing_render_id();
    _d.begin_generation = _t.room_generation; _d.begin_tick = timing_tick_id();
    if (_t.begin_pending) { _d.invalid = "Sequence probe Begin outside complete native boundary"; return; }
    try {
    if (_d.stage == "restart-entry") {
        if (!_d.room_end_seen || room != r_gameplay_qa || _t.room_generation == _d.restart_old_generation
            || !sequence_qa_active()) return;
        _d.current_generation = _t.room_generation; _d.stage = "observing"; _d.restart_arrived = true;
        sequence_probe_qa_log("native-restart-new-complete-begin");
    }
    for (var _e = 0; _e < array_length(_d.extras); ++_e) {
        if (!_d.extras[_e].pending_entry) continue;
        var _clock = timing_sequence_state(_d.extras[_e].element);
        if (is_struct(_clock) && qa_value(_clock, "generation", -1) == _t.room_generation
            && qa_value(_clock, "roomOpen", false) && !qa_value(_clock, "pendingBirth", true)) {
            _d.extras[_e].generation = _t.room_generation; _d.extras[_e].pending_entry = false;
        }
    }
    if (!_d.started && _q.started && !_q.preparing) {
        _d.started = true; _d.current_generation = _t.room_generation;
    }
    if (_d.started && _d.current_generation != _t.room_generation) { _d.invalid = "Unexpected sequence probe generation change"; return; }
    // Destroy only diagnostic dynamic assets whose real old native room has
    // already ended and a new complete Begin now exists. Never query old IDs.
    if (_d.restart_arrived) {
        for (var _f = 0; _f < array_length(_d.retired_frame_assets); ++_f) {
            sequence_destroy(_d.retired_frame_assets[_f]); _d.assets_destroyed += 1;
        }
        _d.retired_frame_assets = [];
    }
    if (!_d.started || !timing_is_tick() || _d.invalid != "") return;
    var _tick = _d.completed_ticks + 1;
    if (_d.kind == "native-public-intent-v1") {
        var _actions = _d.spec.actions;
        if (_d.action_index < array_length(_actions) && _actions[_d.action_index].tick == _tick) {
            var _a = _actions[_d.action_index], _element = _q.sequence_observation.element;
            if (_a.api == "timing_sequence_speedscale") timing_sequence_speedscale(_element, _a.value);
            else if (_a.api == "timing_sequence_pause") timing_sequence_pause(_element);
            else timing_sequence_play(_element);
            _d.action_index += 1;
            sequence_probe_qa_log(_a.api + "@" + string(_tick));
        }
    } else if (_d.kind == "native-late-birth-v1" && _tick == _d.spec.setScaleOneAtTick) {
        if (_d.late_created) {
            timing_sequence_speedscale(_d.extras[0].element, 1); _d.late_scale_applied = true;
            sequence_probe_qa_log("late-native-scale-one", _d.extras[0]);
        } else _d.late_scale_tick_missed = true;
    }
    } catch (_error) { _d.invalid = sequence_qa_error(_error); }
}
function sequence_probe_qa_step() {
    if (!sequence_probe_qa_active() || global.tcc_qa.finished) return;
    var _d = global.tcc_qa.sequence_probe;
    if (_d.invalid != "" || !_d.started || _d.kind != "native-late-birth-v1"
        || _d.late_created || timing_is_tick() || _d.completed_ticks < _d.spec.createOnFirstSkippedOuterAfterTick) return;
    try {
        var _layer = layer_create(-192, "TCC_SequenceQA_LateBirth");
        var _element = timing_sequence_create(_layer, 576, 6720, seq_magentaswing);
        var _e = {label:"late-native-magentaswing", layer:_layer, element:_element,
            generation:global.tcc_timing.room_generation, graphic_expected:true, pending_entry:false};
        array_push(_d.extras, _e);
        sequence_probe_qa_log("late-native-create-return", _e);
        timing_sequence_play(_element); sequence_probe_qa_log("late-native-play-return", _e);
        timing_sequence_speedscale(_element, 0); sequence_probe_qa_log("late-caller-final-zero-return", _e);
        _d.late_created = true;
    } catch (_error) { _d.invalid = sequence_qa_error(_error); }
}
function sequence_probe_qa_sample(_phase, _draw_context = false) {
    if (!sequence_probe_qa_active() || global.tcc_qa.finished) return;
    var _d = global.tcc_qa.sequence_probe;
    if (_d.invalid != "") return;
    if (!is_bool(_draw_context) || !array_contains(["root-begin", "root-step", "root-end", "pre-draw", "ordinary-draw", "post-draw"], _phase)
        || ((_phase == "ordinary-draw") != _draw_context)) { _d.invalid = "Invalid native probe sample context"; return; }
    if (!_d.started && array_length(_d.preparation_samples) >= 64) { _d.preparation_truncated = true; return; }
    if (_d.started && array_length(_d.samples) >= 12000) { _d.samples_truncated = true; _d.dropped_samples += 1; return; }
    var _s = sequence_probe_qa_stamp(_phase, _draw_context); _s.extras = [];
    for (var _e = 0; _e < array_length(_d.extras); ++_e)
        array_push(_s.extras, sequence_probe_qa_element_state(_d.extras[_e]));
    variable_struct_set(_d.phase_counts, _phase, qa_value(_d.phase_counts, _phase, 0) + 1);
    if (_d.started) array_push(_d.samples, _s); else array_push(_d.preparation_samples, _s);
}
function sequence_probe_qa_end() {
    if (!sequence_probe_qa_active() || global.tcc_qa.finished) return;
    var _d = global.tcc_qa.sequence_probe, _t = global.tcc_timing;
    if (_d.last_end_outer == timing_render_id()) { _d.duplicate_ends += 1; return; }
    _d.last_end_outer = timing_render_id();
    var _paired = _d.begin_outer == timing_render_id() && _d.begin_generation == _t.room_generation
        && _d.begin_tick == timing_tick_id() && !_t.begin_pending && _t.ended_render == timing_render_id();
    if (!_paired) { _d.partial_ends += 1; return; }
    _d.last_paired_end = timing_render_id();
    if (!_d.started || !timing_is_tick() || _d.stage != "observing" || _d.invalid != "") return;
    _d.completed_ticks += 1;
    if (_d.kind == "native-production-pause-lifecycle-v1") {
        if (global.pause != 0) { _d.pause_seen = true; _d.pause_ticks += 1; }
        else if (_d.pause_seen) _d.resume_seen = true;
        if (_d.completed_ticks >= 120 && _d.pause_seen && _d.resume_seen && !_d.restart_queued) {
            if (!instance_exists(o_pausesystem)) { _d.invalid = "Native normal pause controller disappeared"; return; }
            _d.restart_queued = true; _d.stage = "restart-pending";
            _d.restart_old_generation = _t.room_generation;
            sequence_probe_qa_log("normal-calibration-room-restart-request");
            room_restart();
        }
    }
}
function sequence_probe_qa_end_ready() {
    if (!sequence_probe_qa_active()) return true;
    var _d = global.tcc_qa.sequence_probe;
    if (_d.invalid != "") { global.tcc_qa.invalid = _d.invalid; return true; }
    return _d.last_paired_end == timing_render_id()
        && _d.begin_generation == global.tcc_timing.room_generation
        && _d.begin_tick == timing_tick_id();
}
function sequence_probe_qa_room_end() {
    if (!sequence_probe_qa_active() || global.tcc_qa.finished) return;
    var _q = global.tcc_qa, _d = _q.sequence_probe;
    if (array_length(_d.lifecycle) >= 4 || array_length(_d.sequence_segments) >= 2) {
        _d.invalid = "Native sequence lifecycle exceeded bounded restart"; return;
    }
    array_push(_d.lifecycle, sequence_probe_qa_stamp("native-room-end"));
    if (variable_struct_exists(_q, "sequence_observation")) {
        array_push(_d.sequence_segments, sequence_qa_summary());
        variable_struct_remove(_q, "sequence_observation");
    }
    if (is_struct(_d.frame_asset)) array_push(_d.retired_frame_assets, _d.frame_asset);
    _d.frame_asset = undefined; _d.extras = [];
    _d.room_end_seen = true;
    if (_d.stage != "restart-pending" || _d.kind != "native-production-pause-lifecycle-v1") {
        _d.invalid = "Unexpected real sequence fixture room exit"; return;
    }
    _d.stage = "restart-entry"; global.tcc_qa.recovery_pending = true;
}
function sequence_probe_qa_summary() {
    if (!sequence_probe_qa_active()) return undefined;
    var _d = global.tcc_qa.sequence_probe;
    return {schemaVersion:1, fixture:_d.fixture, kind:_d.kind, verdict:"unassessed", invalid:_d.invalid,
        diagnosticOnly:true, ordinaryInputProof:false, completedTicks:_d.completed_ticks,
        started:_d.started, stage:_d.stage, duplicateBegins:_d.duplicate_begins,
        duplicateEnds:_d.duplicate_ends, partialEnds:_d.partial_ends,
        actions:_d.actions, actionsTruncated:_d.actions_truncated, actionIndex:_d.action_index,
        samples:_d.samples, preparationSamples:_d.preparation_samples, preparationTruncated:_d.preparation_truncated,
        samplesTruncated:_d.samples_truncated, droppedSamples:_d.dropped_samples,
        phaseCounts:_d.phase_counts, lateCreationExercised:_d.late_created,
        lateScaleApplied:_d.late_scale_applied, lateScaleTickMissed:_d.late_scale_tick_missed,
        lateCoverage:_d.kind == "native-late-birth-v1" && !_d.late_created ? "unexercised" : "unassessed",
        pauseSeen:_d.pause_seen, resumeSeen:_d.resume_seen, pauseTicks:_d.pause_ticks,
        restartQueued:_d.restart_queued, nativeRoomEndSeen:_d.room_end_seen, restartArrived:_d.restart_arrived,
        lifecycle:_d.lifecycle, sequenceSegments:_d.sequence_segments, setupEntries:_d.setup_entries,
        retiredAssetsPending:array_length(_d.retired_frame_assets), assetsDestroyed:_d.assets_destroyed,
        liveDynamicAssetRetainedUntilNativeTeardown:is_struct(_d.frame_asset), maxSamples:12000};
}
function sequence_probe_qa_export(_result) {
    if (!sequence_probe_qa_active()) return;
    _result.diagnosticOnly = true; _result.ordinaryInputProof = false;
    _result.sequenceClockProbe = sequence_probe_qa_summary();
}
