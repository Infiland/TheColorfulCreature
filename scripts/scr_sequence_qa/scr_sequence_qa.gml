/// Optional diagnostic only. Setup adds one untouched native graphic sequence
/// and a sprite-less Draw observer after the normal SP calibration is created.
/// Root owns hook wiring and result export. No native events are dispatched.
function sequence_qa_value(_record, _name, _fallback) {
    return is_struct(_record) && variable_struct_exists(_record, _name)
        ? variable_struct_get(_record, _name) : _fallback;
}

function sequence_qa_error(_error) {
    return sequence_qa_value(_error, "message", string(_error));
}

function sequence_qa_integer(_record, _name, _fallback, _minimum, _maximum) {
    var _value = sequence_qa_value(_record, _name, _fallback);
    if (!is_real(_value) || is_bool(_value) || is_nan(_value) || is_infinity(_value)
        || _value != floor(_value) || _value < _minimum || _value > _maximum)
        throw "Sequence QA invalid " + _name;
    return _value;
}

function sequence_qa_active() {
    if (!TCC_GAMEPLAY_QA || !qa_active()) return false;
    return variable_struct_exists(global.tcc_qa, "sequence_observation")
        && is_struct(global.tcc_qa.sequence_observation)
        && global.tcc_qa.sequence_observation.invalid == "";
}

function sequence_qa_state() {
    var _c = global.tcc_qa.sequence_observation;
    var _state = {roomMatches:room == _c.setup_room, readSucceeded:false,
        layerRef:_c.layer, sequenceElementRef:_c.element,
        expectedAssetName:"seq_magentaswing", graphic:{available:false}};
    try {
        // Preserve original native reference and presence values without casts.
        _state.layerPresentNative = layer_exists(_c.layer);
        _state.layerPresent = _state.layerPresentNative != 0;
        _state.elementPresenceQueried = _state.layerPresent;
        _state.elementPresentNative = _state.layerPresent
            ? layer_sequence_exists(_c.layer, _c.element) : false;
        _state.elementPresent = _state.elementPresentNative != 0;
        if (!_state.roomMatches || !_state.elementPresent) return _state;
        var _instance = layer_sequence_get_instance(_c.element);
        var _asset = layer_sequence_get_sequence(_c.element);
        _state.assetName = _asset.name;
        _state.length = _asset.length;
        _state.loopMode = _asset.loopmode;
        _state.playbackSpeed = _asset.playbackSpeed;
        _state.playbackSpeedType = _asset.playbackSpeedType;
        _state.headPosition = layer_sequence_get_headpos(_c.element);
        _state.headDirection = layer_sequence_get_headdir(_c.element);
        _state.speedScale = layer_sequence_get_speedscale(_c.element);
        _state.sequenceClock = timing_sequence_state(_c.element);
        _state.paused = layer_sequence_is_paused(_c.element);
        _state.finished = layer_sequence_is_finished(_c.element);
        _state.elementPose = {x:layer_sequence_get_x(_c.element),
            y:layer_sequence_get_y(_c.element), angle:layer_sequence_get_angle(_c.element),
            xscale:layer_sequence_get_xscale(_c.element), yscale:layer_sequence_get_yscale(_c.element)};
        _state.readSucceeded = true;
        try {
            // The one known top-level graphic track is read by exact index.
            // Sequence arrays are native pseudoarrays: no array API is used.
            // Data can be absent before the first actual Sequence Begin Step.
            var _track = _instance.activeTracks[0];
            if (is_undefined(_track)) return _state;
            var _graphic = {available:true, spriteRef:_track.spriteIndex,
                posx:_track.posx, posy:_track.posy, rotation:_track.rotation,
                xorigin:_track.xorigin, yorigin:_track.yorigin,
                scalex:_track.scalex, scaley:_track.scaley,
                imageindex:_track.imageindex, imagespeed:_track.imagespeed,
                matrixAvailable:false};
            try {
                var _matrix = _track.matrix;
                if (!is_array(_matrix) || array_length(_matrix) != 16)
                    throw "Sequence QA graphic matrix is not a 16-value native array";
                var _copy = [];
                for (var _m = 0; _m < 16; ++_m) {
                    var _entry = _matrix[_m];
                    if (!is_real(_entry) || is_bool(_entry) || is_nan(_entry) || is_infinity(_entry))
                        throw "Sequence QA graphic matrix contains a nonfinite value";
                    array_push(_copy, _entry);
                }
                _graphic.matrix = _copy;
                _graphic.matrixAvailable = true;
            } catch (_matrix_error) {
                _graphic.matrixReadError = sequence_qa_error(_matrix_error);
            }
            _state.graphic = _graphic;
        } catch (_graphic_error) {
            _state.graphic.readError = sequence_qa_error(_graphic_error);
        }
    } catch (_error) {
        _state.readError = sequence_qa_error(_error);
    }
    return _state;
}

function sequence_qa_stamp(_phase, _draw_context) {
    var _q = global.tcc_qa, _c = _q.sequence_observation, _t = global.tcc_timing;
    return {phase:_phase, serial:_c.sample_serial, room:room_get_name(room),
        roomGeneration:_t.room_generation, outerId:timing_render_id(), tickId:timing_tick_id(),
        isTick:timing_is_tick(), simulationFrame:_q.frame, qaStarted:_q.started, qaPreparing:_q.preparing,
        relativeTick:_c.recording ? timing_tick_id() - _c.start_tick : undefined,
        relativeOuter:_c.recording ? timing_render_id() - _c.start_outer : undefined,
        recording:_c.recording, setupTickDelta:timing_tick_id() - _c.setup_tick,
        setupOuterDelta:timing_render_id() - _c.setup_outer,
        elapsedUs:get_timer() - _c.setup_us,
        recordingElapsedUs:_c.recording ? get_timer() - _c.start_us : undefined,
        generatedDrawFrames:_t.drawn_frames, drawScheduled:_t.draw_frame,
        nativeOuterHz:game_get_speed(gamespeed_fps), requestedRenderCap:global.renderfps,
        gameplayHz:global.maxfps, paused:global.pause != 0,
        accumulatorUs:_t.accumulator_us, outerElapsedUs:_t.elapsed_us,
        centralBeginPending:_t.begin_pending, rootEndAlreadyObserved:_t.ended_render == timing_render_id(),
        drawContext:_draw_context, viewIndex:_draw_context ? view_current : undefined,
        nativeEventType:event_type, nativeEventNumber:event_number};
}

// Begin/End/Pre/Post are called by the root controller; only the new object's
// ordinary Draw event passes true. This function only writes diagnostic state.
function sequence_qa_sample(_phase, _draw_context = false) {
    if (!sequence_qa_active()) return;
    var _q = global.tcc_qa, _c = _q.sequence_observation;
    if (!_q.running || _q.finished) return;
    if (_phase == "root-step" && sequence_qa_value(_c.spec, "observeStep", false) != true) return;
    if (!is_string(_phase) || !is_bool(_draw_context)
        || !array_contains(["root-begin", "root-step", "root-end", "pre-draw", "ordinary-draw", "post-draw"], _phase)
        || ((_phase == "ordinary-draw") != _draw_context)) {
        _c.invalid = "Invalid sequence observation phase/context";
        return;
    }
    if (!_c.recording && _q.started && !_q.preparing && _phase == "root-begin") {
        _c.recording = true;
        _c.start_tick = timing_tick_id(); _c.start_outer = timing_render_id();
        _c.start_us = get_timer(); _c.start_simulation_frame = _q.frame;
    }
    if (_c.recording && _phase == "root-begin") {
        if (_c.last_begin_outer == timing_render_id()) _c.duplicate_begins += 1;
        else _c.outer_count += 1;
        _c.last_begin_outer = timing_render_id();
        if (_c.outer_count > _c.max_outer) _c.outer_limit_reached = true;
    }
    if (_c.outer_limit_reached || (_c.recording && array_length(_c.samples) >= _c.max_samples)) {
        _c.samples_truncated = true; _c.dropped_samples += 1;
        return;
    }
    if (!_c.recording && array_length(_c.preparation_samples) >= 64) {
        _c.preparation_truncated = true; _c.dropped_preparation_samples += 1;
        return;
    }
    var _read_start = get_timer();
    _c.sample_serial += 1;
    var _sample = sequence_qa_stamp(_phase, _draw_context);
    _sample.state = sequence_qa_state();
    if (_phase == "ordinary-draw" && _draw_context) {
        var _draw_context_record = {schemaVersion:1,
            actualDrawContext:event_type == ev_draw && event_number == 0,
            readSucceeded:false, complete:false};
        try {
            if (!_draw_context_record.actualDrawContext)
                throw "Sequence QA applied context requires a genuine ordinary Draw";
            _draw_context_record.activeCamera = camera_get_active();
            _draw_context_record.viewIndex = view_current;
            _draw_context_record.viewEnabled = view_enabled;
            var _view = _draw_context_record.viewIndex;
            if (!is_real(_view) || is_bool(_view) || is_nan(_view) || is_infinity(_view)
                || _view != floor(_view) || _view < 0 || _view > 7)
                throw "Sequence QA applied Draw has an invalid native viewport index";
            // Copy native viewport entries individually: built-ins are pseudoarrays.
            _draw_context_record.viewportPort = [view_xport[_view], view_yport[_view],
                view_wport[_view], view_hport[_view]];
            for (var _port_entry = 0; _port_entry < 4; ++_port_entry) {
                var _port_value = _draw_context_record.viewportPort[_port_entry];
                if (!is_real(_port_value) || is_bool(_port_value) || is_nan(_port_value) || is_infinity(_port_value))
                    throw "Sequence QA applied Draw has a nonfinite native viewport entry";
            }
            // Read matrices actually applied in this callback. No configured camera substitute.
            _draw_context_record.matrices = {
                world:camera_qa_matrix(matrix_get(matrix_world), "sequence-applied-world"),
                view:camera_qa_matrix(matrix_get(matrix_view), "sequence-applied-view"),
                projection:camera_qa_matrix(matrix_get(matrix_projection), "sequence-applied-projection")};
            _draw_context_record.applicationSurface = application_surface;
            _draw_context_record.applicationSurfaceExistsNative = surface_exists(application_surface);
            if (_draw_context_record.applicationSurfaceExistsNative != 0) {
                _draw_context_record.applicationSurfaceSize = [surface_get_width(application_surface),
                    surface_get_height(application_surface)];
                for (var _surface_entry = 0; _surface_entry < 2; ++_surface_entry) {
                    var _surface_value = _draw_context_record.applicationSurfaceSize[_surface_entry];
                    if (!is_real(_surface_value) || is_bool(_surface_value) || is_nan(_surface_value) || is_infinity(_surface_value)
                        || _surface_value <= 0)
                        throw "Sequence QA applied Draw has an invalid native application surface size";
                }
                _draw_context_record.complete = _draw_context_record.viewEnabled
                    && _draw_context_record.viewportPort[2] > 0 && _draw_context_record.viewportPort[3] > 0;
            }
            _draw_context_record.readSucceeded = true;
        } catch (_draw_error) {
            _draw_context_record.readErrorType = typeof(_draw_error);
            _draw_context_record.readError = sequence_qa_error(_draw_error);
        }
        _sample.appliedDrawContext = _draw_context_record;
    }
    _sample.observerCostUs = get_timer() - _read_start;
    if (!_sample.state.readSucceeded) _c.read_failures += 1;
    if (!_sample.state.graphic.available) _c.graphic_unavailable += 1;
    variable_struct_set(_c.phase_counts, _phase, sequence_qa_value(_c.phase_counts, _phase, 0) + 1);
    if (_c.recording) {
        array_push(_c.samples, _sample);
        _c.observed_through_tick = max(_c.observed_through_tick, _sample.relativeTick);
        if (_phase == "root-end") {
            _c.last_end_outer = timing_render_id(); _c.last_end_draw_scheduled = _sample.drawScheduled;
        }
        if (_phase == "post-draw") _c.last_post_outer = timing_render_id();
    } else array_push(_c.preparation_samples, _sample);
}

function sequence_qa_setup(_spec = undefined) {
    if (!TCC_GAMEPLAY_QA || !qa_active()) return false;
    var _option = sequence_qa_value(_spec, "sequenceObservation", undefined);
    if (is_undefined(_option)) return false;
    var _q = global.tcc_qa;
    if (variable_struct_exists(_q, "sequence_observation")) return true;
    _q.sequence_observation = {schemaVersion:1, fixture:"native-sequence-observation-v1",
        spec:_option, invalid:"", recording:false, setup_room:room,
        setup_tick:timing_tick_id(), setup_outer:timing_render_id(), setup_us:get_timer(),
        start_tick:undefined, start_outer:undefined, start_us:0, start_simulation_frame:undefined,
        target_ticks:240, max_outer:2048, max_samples:8192,
        layer:noone, element:noone, observer:noone, setup:undefined, calibration:undefined,
        samples:[], preparation_samples:[], phase_counts:{}, sample_serial:0, outer_count:0,
        last_begin_outer:-1, last_end_outer:-1, last_post_outer:-1, last_end_draw_scheduled:false,
        observed_through_tick:-1, duplicate_begins:0, read_failures:0, graphic_unavailable:0,
        samples_truncated:false, dropped_samples:0, outer_limit_reached:false,
        preparation_truncated:false, dropped_preparation_samples:0};
    var _c = _q.sequence_observation;
    try {
        if (!is_struct(_option) || sequence_qa_value(_option, "kind", "") != "magentaswing-v1")
            throw "Sequence QA requires magentaswing-v1 options";
        if (room != r_gameplay_qa || sequence_qa_value(_spec, "fixture", "default") != "default"
            || sequence_qa_value(_spec, "mode", "") != "replay"
            || sequence_qa_value(_spec, "actor", "single-player") != "single-player"
            || variable_struct_exists(_spec, "timingProbe") || variable_struct_exists(_spec, "cameraFixture")
            || variable_struct_exists(_spec, "actorFixture") || variable_struct_exists(_spec, "slopeFixture")
            || variable_struct_exists(_spec, "timingScenario") || variable_struct_exists(_spec, "challenge")
            || variable_struct_exists(_spec, "specialIndex") || variable_struct_exists(_spec, "levelSelect"))
            throw "Sequence QA requires intact default SP calibration";
        if ((_q.started && !sequence_probe_qa_allow_setup()) || _q.preparing)
            throw "Sequence QA setup must precede player recording or follow the real opt-in restart";
        if (!is_bool(sequence_qa_value(_option, "observeStep", false))) throw "Sequence QA observeStep must be boolean";
        _c.target_ticks = sequence_qa_integer(_option, "ticks", 240, 120, 240);
        _c.max_outer = sequence_qa_integer(_option, "maxOuterFrames", 2048, 128, 2048);
        _c.max_samples = sequence_qa_integer(_option, "maxSamples", 8192, 256, 12000);
        if (instance_number(o_player) != 1 || instance_number(o_whiteblock) != 1)
            throw "Sequence QA needs existing normal player and floor";
        var _player = instance_find(o_player, 0), _floor = instance_find(o_whiteblock, 0);
        if (_player.x != 96 || _player.y != 6972 || _floor.x != 0 || _floor.y != 7000
            || _floor.image_xscale != 128) throw "Sequence QA calibration transforms changed before setup";
        _c.calibration = {playerRef:_player, playerObject:o_player, x:_player.x, y:_player.y,
            floorRef:_floor, floorObject:o_whiteblock, floorX:_floor.x, floorY:_floor.y,
            floorXscale:_floor.image_xscale, floorYscale:_floor.image_yscale};
        _c.layer = layer_create(-190, "TCC_SequenceQA_Magenta");
        if (!layer_exists(_c.layer)) throw "Sequence QA layer creation failed";
        _c.element = timing_sequence_create(_c.layer, 384, 6720, seq_magentaswing);
        if (!layer_sequence_exists(_c.layer, _c.element)) throw "Sequence QA native element creation failed";
        // Match reachable Create/Play through the owned native clock wrappers.
        // Asset/track/head/follow values remain untouched by this diagnostic.
        timing_sequence_play(_c.element);
        _c.observer = timing_create_layer(0, 0, _c.layer, o_sequence_qa_observer);
        if (!instance_exists(_c.observer)) throw "Sequence QA Draw observer creation failed";
        _c.setup = sequence_qa_stamp("setup", false);
        _c.setup.state = sequence_qa_state();
    } catch (_error) {
        _c.invalid = sequence_qa_error(_error);
        // Setup failure removes only diagnostic resources it just created.
        try {
            if (instance_exists(_c.observer)) with (_c.observer) instance_destroy();
            if (_c.layer != noone && layer_exists(_c.layer)) layer_destroy(_c.layer);
        } catch (_cleanup_error) {
            _c.invalid += "; setup cleanup: " + sequence_qa_error(_cleanup_error);
        }
    }
    return true;
}

function sequence_qa_summary() {
    if (!TCC_GAMEPLAY_QA || !qa_active()
        || !variable_struct_exists(global.tcc_qa, "sequence_observation")) return undefined;
    var _c = global.tcc_qa.sequence_observation;
    return {schemaVersion:_c.schemaVersion, fixture:_c.fixture, verdict:"unassessed", spec:_c.spec,
        invalid:_c.invalid, recording:_c.recording, setup:_c.setup, calibration:_c.calibration,
        targetTicks:_c.target_ticks, startTick:_c.start_tick, startOuter:_c.start_outer,
        startSimulationFrame:_c.start_simulation_frame, observedThroughTick:_c.observed_through_tick,
        outerCount:_c.outer_count, maxOuterFrames:_c.max_outer, maxSamples:_c.max_samples,
        samples:_c.samples, preparationSamples:_c.preparation_samples, phaseCounts:_c.phase_counts,
        samplesTruncated:_c.samples_truncated, droppedSamples:_c.dropped_samples,
        preparationTruncated:_c.preparation_truncated, droppedPreparationSamples:_c.dropped_preparation_samples,
        outerLimitReached:_c.outer_limit_reached, duplicateBegins:_c.duplicate_begins,
        readFailures:_c.read_failures, graphicUnavailable:_c.graphic_unavailable,
        lastBeginOuter:_c.last_begin_outer, lastEndOuter:_c.last_end_outer, lastPostDrawOuter:_c.last_post_outer,
        terminalEndAwaitingPostDraw:_c.last_end_outer >= 0 && _c.last_end_draw_scheduled
            && _c.last_end_outer != _c.last_post_outer,
        finalState:_c.invalid == "" ? sequence_qa_state() : undefined};
}
