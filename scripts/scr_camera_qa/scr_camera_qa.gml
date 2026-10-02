/// Optional native camera/Draw observation. Nothing in the recorder writes an
/// actor pose, input, camera, matrix, surface, or production timing property.
///
/// Integration owned by the caller:
/// - root-begin: after the final controller Begin flush;
/// - root-end: after authoritative previous/current pose capture, before QA can
///   finish and before the next native outer frame;
/// - pre-draw-authoritative / pre-draw-interpolated: surround timing_before_draw;
/// - view-draw-begin / view-draw-end: ordinary Draw Begin/End, drawContext=true;
/// - actor-draw: optional first line of an existing actor Draw, true, id;
/// - post-draw-before-restore / post-draw-restored: surround timing_after_draw.
/// Only ordinary per-view Draw hooks pass true, never Pre/Post Draw or GUI.
/// Export camera_qa_summary() in the real QA result. A pending final Draw stays
/// explicit: finishing in End Step does not invent the absent Draw samples.
///
/// spec.cameraObservation must be true or a limits struct. False/absent is off.
/// State belongs to this global.tcc_qa, not a persistent independent observer.
/// A successful cameraFixture permits its first complete native root-begin before
/// qa.started, preserving actual frame/scene/phase stamps. Other observers wait
/// until qa.started. The unpaired initial End/Draw remains deferred.
/// Fixture setup is separate: camera_qa_fixture(q.spec) is an optional first
/// branch in qa_calibration_room. It returns false when cameraFixture is absent,
/// true when handled (including an invalid fixture). No hooks are installed here.

function camera_qa_value(_record, _name, _fallback) {
    return is_struct(_record) && variable_struct_exists(_record, _name)
        ? variable_struct_get(_record, _name) : _fallback;
}

function camera_qa_integer(_record, _name, _fallback, _min, _max) {
    var _value = camera_qa_value(_record, _name, _fallback);
    if (!is_real(_value) || is_bool(_value) || is_nan(_value) || is_infinity(_value)
        || _value != floor(_value) || _value < _min || _value > _max)
        throw "Camera QA invalid " + _name;
    return _value;
}

function camera_qa_boolean(_record, _name, _fallback) {
    var _value = camera_qa_value(_record, _name, _fallback);
    if (!is_bool(_value)) throw "Camera QA invalid " + _name;
    return _value;
}

// Pure phase policy; independent offline fixtures can execute these functions
// with array_create/array_push/array_contains/array_length shims. That checks
// policy only, not native event ordering or compiled GML behavior.
function camera_qa_phase_state(_outer, _generation) {
    return {outer:_outer, generation:_generation, beginSeen:false, endSeen:false,
        expectedDraw:false, drawStage:0, drawId:undefined, expectedViews:[],
        viewStages:array_create(8, 0), actorKeys:[]};
}

function camera_qa_phase_apply(_f, _phase, _draw_context, _view, _actor_key) {
    var _issues = [];
    var _draw_phase = array_contains(["view-draw-begin", "actor-draw", "view-draw-end"], _phase);
    if (_draw_phase != _draw_context) array_push(_issues, "draw-context-mismatch");
    if (_phase == "root-begin") {
        if (_f.beginSeen) array_push(_issues, "duplicate-root-begin");
        if (_f.endSeen || _f.drawStage != 0) array_push(_issues, "root-begin-out-of-order");
        _f.beginSeen = true;
    } else if (_phase == "root-end") {
        if (!_f.beginSeen) array_push(_issues, "root-end-without-begin");
        if (_f.endSeen) array_push(_issues, "duplicate-root-end");
        if (_f.drawStage != 0) array_push(_issues, "root-end-after-draw");
        _f.endSeen = true;
    } else if (_phase == "pre-draw-authoritative") {
        if (!_f.beginSeen || !_f.endSeen) array_push(_issues, "pre-draw-without-root-pair");
        if (_f.drawStage != 0) array_push(_issues, "duplicate-or-late-pre-draw");
        if (!_f.expectedDraw) array_push(_issues, "draw-on-unscheduled-outer-frame");
        _f.drawStage = 1;
    } else if (_phase == "pre-draw-interpolated") {
        if (_f.drawStage != 1) array_push(_issues, "interpolation-boundary-out-of-order");
        _f.drawStage = 2;
    } else if (_draw_phase) {
        if (_view < 0 || _view > 7 || _view != floor(_view)) {
            array_push(_issues, "invalid-view-index");
            return _issues;
        }
        if (_f.drawStage != 2) array_push(_issues, "view-draw-outside-interpolated-window");
        if (!array_contains(_f.expectedViews, _view)) array_push(_issues, "unexpected-view-draw");
        if (_phase == "view-draw-begin") {
            if (_f.viewStages[_view] != 0) array_push(_issues, "duplicate-view-begin");
            _f.viewStages[_view] = 1;
        } else if (_phase == "view-draw-end") {
            if (_f.viewStages[_view] != 1) array_push(_issues, "view-end-without-open-begin");
            _f.viewStages[_view] = 2;
        } else {
            if (_f.viewStages[_view] != 1) array_push(_issues, "actor-draw-outside-open-view");
            if (_actor_key == "") array_push(_issues, "actor-draw-without-identity");
            if (array_contains(_f.actorKeys, _actor_key)) array_push(_issues, "duplicate-actor-draw");
            else array_push(_f.actorKeys, _actor_key);
        }
    } else if (_phase == "post-draw-before-restore") {
        if (_f.drawStage != 2) array_push(_issues, "post-draw-out-of-order");
        for (var _i = 0; _i < array_length(_f.expectedViews); ++_i)
            if (_f.viewStages[_f.expectedViews[_i]] != 2) array_push(_issues, "missing-view-pair");
        _f.drawStage = 3;
    } else if (_phase == "post-draw-restored") {
        if (_f.drawStage != 3) array_push(_issues, "restoration-boundary-out-of-order");
        _f.drawStage = 4;
    } else array_push(_issues, "unknown-phase");
    return _issues;
}

function camera_qa_phase_close(_f) {
    var _issues = [];
    if (!_f.beginSeen || !_f.endSeen) array_push(_issues, "incomplete-root-pair");
    if (_f.expectedDraw && _f.drawStage != 4) array_push(_issues, "missing-complete-draw-window");
    if (!_f.expectedDraw && _f.drawStage != 0) array_push(_issues, "unscheduled-draw-window");
    for (var _i = 0; _i < array_length(_f.expectedViews); ++_i)
        if (_f.drawStage > 0 && _f.viewStages[_f.expectedViews[_i]] != 2)
            array_push(_issues, "incomplete-view-pair");
    return _issues;
}

function camera_qa_boot() {
    if (!qa_active()) return false;
    var _q = global.tcc_qa;
    var _spec = camera_qa_value(_q.spec, "cameraObservation", false);
    if (is_bool(_spec) && !_spec) return false;
    if (variable_struct_exists(_q, "camera_observation")) return true;
    try {
        if (!(is_bool(_spec) && _spec) && !is_struct(_spec)) throw "Camera observation must be true or a struct";
        var _max_actors = camera_qa_integer(_spec, "maxActors", 12, 1, 32);
        _q.camera_observation = {schemaVersion:2, spec:_spec, invalid:"", recording:false,
            maxSamples:camera_qa_integer(_spec, "maxSamples", 12000, 64, 50000),
            maxActors:_max_actors,
            maxIdentities:camera_qa_integer(_spec, "maxIdentities", 128, _max_actors, 512),
            maxCandidates:camera_qa_integer(_spec, "maxCandidates", 64, _max_actors, 256),
            maxIssues:camera_qa_integer(_spec, "maxIssues", 128, 1, 1024),
            samples:[], identities:[], selected:[], issues:[], cameraUses:[], phaseCounts:{},
            frame:undefined, closedFrames:0, startTick:undefined, startOuter:undefined,
            drawSequence:0,
            startSimulationFrame:undefined, startUs:0, deferredSamples:0,
            startQaStarted:undefined, startRoomGeneration:undefined, startReason:undefined,
            samplesTruncated:false, identitiesTruncated:false, selectionTruncated:false,
            discoveryTruncated:false, issuesTruncated:false, droppedSamples:0,
            issueCount:0, readFailures:0, matrixFailures:0, fixture:undefined,
            discoveryOuter:-1, discoveryGeneration:-1, fixtureStarts:[], fixtureStartsTruncated:false};
    } catch (_error) {
        _q.camera_observation = {schemaVersion:2, spec:_spec,
            invalid:camera_qa_value(_error, "message", string(_error)), recording:false};
    }
    return true;
}

function camera_qa_issue(_kind, _detail = undefined) {
    var _c = global.tcc_qa.camera_observation;
    _c.issueCount += 1;
    if (array_length(_c.issues) >= _c.maxIssues) { _c.issuesTruncated = true; return; }
    array_push(_c.issues, {kind:_kind, detail:_detail, roomGeneration:global.tcc_timing.room_generation,
        tickId:timing_tick_id(), outerId:timing_render_id(), drawId:global.tcc_timing.drawn_frames});
}

function camera_qa_role(_object) {
    if (_object == o_player) return "player";
    if (_object == o_playerMU) return "multiplayer-player";
    if (_object == o_playerdead) return "dead-player";
    if (_object == o_smoothcamera) return "smooth-camera";
    if (_object == o_smoothcameraboss5) return "boss-camera";
    if (_object == o_gunequipped) return "equipped-gun";
    if (_object == o_torch) return "torch";
    if (_object == o_fire) return "fire";
    return "unsupported";
}

function camera_qa_identity(_who, _role) {
    var _c = global.tcc_qa.camera_observation;
    for (var _i = 0; _i < array_length(_c.identities); ++_i)
        if (_c.identities[_i].instanceId == _who) return _c.identities[_i].registryId;
    if (array_length(_c.identities) >= _c.maxIdentities) { _c.identitiesTruncated = true; return -1; }
    var _index = array_length(_c.identities);
    array_push(_c.identities, {registryId:_index, instanceId:_who, role:_role,
        firstTick:timing_tick_id(), firstOuter:timing_render_id(),
        firstRoomGeneration:global.tcc_timing.room_generation});
    return _index;
}

function camera_qa_discover() {
    var _c = global.tcc_qa.camera_observation, _t = global.tcc_timing;
    // Called at root boundaries, never per actor/per viewport Draw. Enumerate
    // only selected object classes, with a total candidate budget.
    var _objects = [o_player, o_playerMU, o_playerdead, o_smoothcamera,
        o_smoothcameraboss5, o_gunequipped, o_fire, o_torch];
    var _selected = [], _candidates = 0;
    var _candidate_total = 0;
    for (var _o = 0; _o < array_length(_objects); ++_o) _candidate_total += instance_number(_objects[_o]);
    if (_candidate_total > _c.maxCandidates) _c.discoveryTruncated = true;
    for (var _o = 0; _o < array_length(_objects); ++_o) {
        var _object = _objects[_o], _count = instance_number(_object);
        for (var _i = 0; _i < _count; ++_i) {
            if (_candidates >= _c.maxCandidates) { _c.discoveryTruncated = true; break; }
            _candidates += 1;
            var _who = instance_find(_object, _i);
            if (_who == noone || !instance_exists(_who)) continue;
            // Uncollected torches are scenery/pickups, not attached followers.
            if (_object == o_torch && !_who.holding && !_who.died) continue;
            if (array_contains(_selected, _who)) continue;
            if (array_length(_selected) >= _c.maxActors) { _c.selectionTruncated = true; continue; }
            if (camera_qa_identity(_who, camera_qa_role(_who.object_index)) >= 0) array_push(_selected, _who);
        }
        if (_candidates >= _c.maxCandidates) break;
    }
    // Retain an inactive actor only while its native ID is genuinely readable.
    // Never activate it to obtain a sample; destruction/read failures are explicit.
    if (_c.discoveryGeneration == _t.room_generation) {
        for (var _p = 0; _p < array_length(_c.selected); ++_p) {
            var _old = _c.selected[_p];
            if (array_contains(_selected, _old) || instance_exists(_old)) continue;
            try {
                var _object = _old.object_index;
                if (camera_qa_role(_object) != "unsupported") {
                    if (array_length(_selected) < _c.maxActors) array_push(_selected, _old);
                    else _c.selectionTruncated = true;
                }
            } catch (_error) {
                // This reports unavailable lifecycle access, not proof that a
                // destroyed actor was an inactive one. No fictional pose follows.
                _c.readFailures += 1;
                camera_qa_issue("retained-id-unavailable", {instanceId:_old,
                    error:camera_qa_value(_error, "message", string(_error))});
            }
        }
    }
    _c.selected = _selected;
    _c.discoveryOuter = timing_render_id();
    _c.discoveryGeneration = _t.room_generation;
}

function camera_qa_instance_value(_who, _name, _fallback = undefined) {
    return variable_instance_exists(_who, _name) ? variable_instance_get(_who, _name) : _fallback;
}

function camera_qa_actor(_who) {
    var _c = global.tcc_qa.camera_observation, _active = instance_exists(_who);
    try {
        var _object = _who.object_index, _role = camera_qa_role(_object);
        var _state = {instanceId:_who, registryId:camera_qa_identity(_who, _role), role:_role,
            objectId:_object, objectName:object_get_name(_object), present:_active, active:_active,
            inactiveReadSucceeded:!_active, snapshotOnly:true,
            x:_who.x, y:_who.y, xprevious:_who.xprevious, yprevious:_who.yprevious,
            hsp:camera_qa_instance_value(_who, "hsp"), vsp:camera_qa_instance_value(_who, "vsp"),
            speed:_who.speed, direction:_who.direction, hspeed:_who.hspeed, vspeed:_who.vspeed,
            sprite:_who.sprite_index, mask:_who.mask_index,
            imageIndex:_who.image_index, imageAngle:_who.image_angle,
            imageXscale:_who.image_xscale, imageYscale:_who.image_yscale,
            imageAlpha:_who.image_alpha, visible:_who.visible, depth:_who.depth,
            bbox:[_who.bbox_left, _who.bbox_top, _who.bbox_right, _who.bbox_bottom],
            timing:undefined, state:{}, attachment:undefined, inlineGun:undefined};
        var _sprite = _who.sprite_index;
        if (sprite_exists(_sprite)) {
            _state.spriteName = sprite_get_name(_sprite);
            _state.spriteOrigin = [sprite_get_xoffset(_sprite), sprite_get_yoffset(_sprite)];
        }
        var _mask = _who.mask_index == -1 ? _sprite : _who.mask_index;
        _state.effectiveMask = _mask;
        if (sprite_exists(_mask)) {
            _state.maskName = sprite_get_name(_mask);
            _state.maskOrigin = [sprite_get_xoffset(_mask), sprite_get_yoffset(_mask)];
        }
        var _native = camera_qa_instance_value(_who, "timing_native");
        if (is_struct(_native)) _state.timing = {previousX:_native.previous_x, previousY:_native.previous_y,
            currentX:_native.current_x, currentY:_native.current_y, startX:_native.start_x, startY:_native.start_y,
            savedDrawX:_native.draw_x, savedDrawY:_native.draw_y, interpolated:_native.interpolated,
            held:_native.held, authoritativeSpeed:_native.speed, authoritativeDirection:_native.direction};
        var _fields = ["zerogrv", "teleportcooldown", "portallast", "holding", "died", "torchcount",
            "firedeath", "xcord", "ycord", "timer", "gunrotation", "hasgun", "ammo", "breath",
            "onGround", "inwater", "key_left", "key_right", "key_jump", "key_interact", "key_interact_h",
            "key_restart", "input_jump_held", "customskin", "customskin_spr", "xchange", "ychange"];
        for (var _i = 0; _i < array_length(_fields); ++_i)
            if (variable_instance_exists(_who, _fields[_i]))
                variable_struct_set(_state.state, _fields[_i], variable_instance_get(_who, _fields[_i]));
        if (_role == "equipped-gun" || _role == "torch" || _role == "fire") {
            var _live = instance_find(o_player, 0), _dead = instance_find(o_playerdead, 0), _owner = noone;
            if (_live != noone && instance_exists(_live)) _owner = _live;
            if (_role == "fire" && _dead != noone && instance_exists(_dead)) _owner = _dead;
            if (_role == "torch" && (!camera_qa_instance_value(_who, "holding", false)
                || camera_qa_instance_value(_who, "died", false))) _owner = noone;
            _state.attachment = {association:"source-step-priority; not an assigned binding",
                livePlayer:_live, deadPlayer:_dead, sourceOwner:_owner, worldDelta:undefined};
            if (_owner != noone) _state.attachment.worldDelta = [_who.x - _owner.x, _who.y - _owner.y];
        }
        if (_role == "multiplayer-player" && camera_qa_instance_value(_who, "hasgun", false))
            _state.inlineGun = {source:"o_playerMU/Draw_0",
                x:_who.x + _who.xcord + 9 - _who.xchange,
                y:_who.y + _who.ycord + 23 - _who.ychange,
                frame:_who.gunframe, angle:_who.gunangle};
        return _state;
    } catch (_error) {
        _c.readFailures += 1;
        camera_qa_issue("actor-read-failure", {instanceId:_who, active:_active,
            error:camera_qa_value(_error, "message", string(_error))});
        return {instanceId:_who, present:_active, active:_active, readSucceeded:false,
            inactiveReadSucceeded:false, snapshotOnly:true};
    }
}

function camera_qa_target(_target) {
    var _record = {rawRef:_target, kind:"unresolved-native-reference"};
    if (_target == -1 || _target == noone) { _record.kind = "none"; return _record; }
    try {
        if (asset_get_type(_target) == asset_object) {
            _record.kind = "object"; _record.objectName = object_get_name(_target); return _record;
        }
    } catch (_error) { /* Preserve the actual reference even if its asset type is unavailable. */ }
    try {
        _record.objectName = object_get_name(_target.object_index);
        _record.kind = "instance"; _record.active = instance_exists(_target);
    } catch (_error) { /* Never choose an arbitrary instance for an object follow target. */ }
    return _record;
}

// Configured getters preserve actual native values without applying a camera.
// Each query keeps its own error; a provisional matrix does not invalidate an
// otherwise readable geometry descriptor or replace it with a synthetic matrix.
function camera_qa_configured_query(_operation, _camera) {
    var _record = {operation:_operation, ok:false, nativeType:undefined,
        value:undefined, error:undefined};
    try {
        var _value = undefined;
        switch (_operation) {
            case "camera_get_view_mat": _value = camera_get_view_mat(_camera); break;
            case "camera_get_proj_mat": _value = camera_get_proj_mat(_camera); break;
            case "camera_get_update_script": _value = camera_get_update_script(_camera); break;
            default: throw "Unsupported configured camera query";
        }
        _record.nativeType = typeof(_value);
        if (_operation == "camera_get_update_script") {
            // Preserve the native reference. Do not cast it or invoke it.
            // Unobserved custom-method JSON serialization remains outside the
            // bounded default/owned-callback fixture qualification.
            _record.value = _value;
            _record.nativeString = string(_value);
            _record.equalsNone = _value == -1;
            _record.equalsTimingCamera = _value == timing_camera_native_disabled;
        } else _record.value = camera_qa_matrix(_value, _operation);
        _record.ok = true;
    } catch (_error) {
        _record.error = camera_qa_value(_error, "message", string(_error));
    }
    return _record;
}

function camera_qa_configured_native(_camera) {
    var _c = global.tcc_qa.camera_observation, _prior_use = false;
    for (var _i = 0; _i < array_length(_c.cameraUses); ++_i)
        if (_c.cameraUses[_i].cameraId == _camera
            && _c.cameraUses[_i].generation == global.tcc_timing.room_generation) _prior_use = true;
    var _record = {schemaVersion:1, configuredOnly:true,
        matrixValidity:_prior_use ? "prior-viewport-use-observed" : "first-use-provisional",
        viewMatrix:camera_qa_configured_query("camera_get_view_mat", _camera),
        projectionMatrix:camera_qa_configured_query("camera_get_proj_mat", _camera),
        updateScript:camera_qa_configured_query("camera_get_update_script", _camera)};
    var _queries = [_record.viewMatrix, _record.projectionMatrix, _record.updateScript];
    for (var _q = 0; _q < array_length(_queries); ++_q) {
        if (_queries[_q].ok) continue;
        if (_queries[_q].operation == "camera_get_update_script") _c.readFailures += 1;
        else _c.matrixFailures += 1;
        camera_qa_issue("configured-native-query-failure", {cameraId:_camera, query:_queries[_q],
            matrixValidity:_record.matrixValidity});
    }
    return _record;
}

function camera_qa_camera(_camera) {
    if (_camera == -1) return {cameraId:_camera, available:false};
    try {
        return {cameraId:_camera, available:true,
            view:[camera_get_view_x(_camera), camera_get_view_y(_camera),
                camera_get_view_width(_camera), camera_get_view_height(_camera)],
            angle:camera_get_view_angle(_camera),
            border:[camera_get_view_border_x(_camera), camera_get_view_border_y(_camera)],
            followSpeed:[camera_get_view_speed_x(_camera), camera_get_view_speed_y(_camera)],
            target:camera_qa_target(camera_get_view_target(_camera)),
            configuredNative:camera_qa_configured_native(_camera)};
    } catch (_error) {
        global.tcc_qa.camera_observation.readFailures += 1;
        camera_qa_issue("camera-read-failure", {cameraId:_camera,
            error:camera_qa_value(_error, "message", string(_error))});
        return {cameraId:_camera, available:false, readSucceeded:false};
    }
}

function camera_qa_configured_views() {
    var _views = [];
    // These built-in viewport arrays are not normal GML arrays. Copy individual
    // entries; do not pass the built-ins directly to JSON or array functions.
    for (var _v = 0; _v < 8; ++_v) {
        var _record = {viewport:_v, enabled:view_enabled, visible:view_visible[_v],
            port:[view_xport[_v], view_yport[_v], view_wport[_v], view_hport[_v]],
            cameraId:view_camera[_v], configuredOnly:true};
        if (view_enabled && view_visible[_v]) _record.camera = camera_qa_camera(view_camera[_v]);
        array_push(_views, _record);
    }
    return {enabled:view_enabled, implicitDefault:!view_enabled, views:_views};
}

function camera_qa_matrix(_matrix, _name) {
    if (!is_array(_matrix) || array_length(_matrix) != 16) throw "Invalid camera QA " + _name + " matrix";
    var _copy = [];
    for (var _i = 0; _i < 16; ++_i) {
        var _value = _matrix[_i];
        if (!is_real(_value) || is_bool(_value) || is_nan(_value) || is_infinity(_value))
            throw "Nonfinite camera QA " + _name + " matrix";
        array_push(_copy, _value);
    }
    return _copy;
}

function camera_qa_draw_camera(_phase) {
    var _c = global.tcc_qa.camera_observation, _active = camera_get_active(), _prior_use = false;
    if (view_current < 0 || view_current > 7 || view_current != floor(view_current)) {
        camera_qa_issue("draw-camera-invalid-view", view_current);
        return {actualDrawContext:true, activeCamera:_active, viewport:view_current, readSucceeded:false};
    }
    var _generation = global.tcc_timing.room_generation;
    for (var _i = 0; _i < array_length(_c.cameraUses); ++_i)
        if (_c.cameraUses[_i].cameraId == _active && _c.cameraUses[_i].generation == _generation)
            _prior_use = true;
    var _record = {activeCamera:_active, viewport:view_current, viewEnabled:view_enabled,
        matchesConfiguredCamera:view_enabled ? _active == view_camera[view_current] : undefined,
        actualDrawContext:true, camera:camera_qa_camera(_active), matrices:undefined,
        cameraMatrices:undefined, priorViewportUseObserved:_prior_use,
        cameraMatrixValidity:_prior_use ? "prior-viewport-use-observed" : "first-use-provisional"};
    try {
        // Applied matrices belong to this real Draw context, not a configured
        // camera read at Begin/End. No camera_apply/matrix_set is used.
        _record.matrices = {world:camera_qa_matrix(matrix_get(matrix_world), "applied-world"),
            view:camera_qa_matrix(matrix_get(matrix_view), "applied-view"),
            projection:camera_qa_matrix(matrix_get(matrix_projection), "applied-projection")};
        if (_active != -1) _record.cameraMatrices = {
            view:camera_qa_matrix(camera_get_view_mat(_active), "camera-view"),
            projection:camera_qa_matrix(camera_get_proj_mat(_active), "camera-projection")};
    } catch (_error) {
        _c.matrixFailures += 1;
        camera_qa_issue("draw-matrix-read-failure", camera_qa_value(_error, "message", string(_error)));
    }
    if (_phase == "view-draw-end" && _active != -1 && !_prior_use) {
        if (array_length(_c.cameraUses) < _c.maxIdentities) {
            array_push(_c.cameraUses, {cameraId:_active, generation:_generation,
                firstCompletedDraw:global.tcc_timing.drawn_frames});
            _record.cameraMatrixValidity = "first-viewport-use-completed";
        } else { _c.identitiesTruncated = true; }
    }
    return _record;
}

function camera_qa_sample(_phase, _draw_context = false, _who = noone) {
    if (!camera_qa_boot()) return;
    var _q = global.tcc_qa, _c = _q.camera_observation;
    if (_c.invalid != "" || !_q.running || _q.finished || _q.preparing
        || !variable_global_exists("tcc_timing")) return;
    if (!is_string(_phase) || !is_bool(_draw_context)) {
        camera_qa_issue("invalid-sample-arguments", {phase:_phase, drawContext:_draw_context});
        return;
    }
    if (!_c.recording) {
        var _fixture_begin = is_struct(_c.fixture) && !global.tcc_timing.first && timing_is_tick();
        if (_phase != "root-begin" || (!_q.started && !_fixture_begin)) {
            _c.deferredSamples += 1; return;
        }
        _c.recording = true; _c.startTick = timing_tick_id(); _c.startOuter = timing_render_id();
        _c.startSimulationFrame = _q.frame; _c.startUs = get_timer();
        _c.startQaStarted = _q.started; _c.startRoomGeneration = global.tcc_timing.room_generation;
        _c.startReason = !_q.started && _fixture_begin
            ? "camera-fixture-first-complete-begin" : "qa-started-first-root-begin";
    }
    if (array_length(_c.samples) >= _c.maxSamples) {
        _c.samplesTruncated = true; _c.droppedSamples += 1; return;
    }
    var _t = global.tcc_timing, _outer = timing_render_id(), _generation = _t.room_generation;
    if (is_undefined(_c.frame) || _c.frame.outer != _outer || _c.frame.generation != _generation) {
        if (!is_undefined(_c.frame)) {
            var _close = camera_qa_phase_close(_c.frame);
            for (var _i = 0; _i < array_length(_close); ++_i)
                camera_qa_issue(_close[_i], {outer:_c.frame.outer, generation:_c.frame.generation});
            _c.closedFrames += 1;
        }
        _c.frame = camera_qa_phase_state(_outer, _generation);
        _c.frame.expectedDraw = _t.draw_frame;
    }
    // A wrongly wired Pre/Post/GUI hook must not read the active camera merely
    // because its caller supplied true. Keep the mismatch as explicit evidence.
    var _ordinary_draw = _draw_context && array_contains(["view-draw-begin", "actor-draw", "view-draw-end"], _phase);
    var _view = _ordinary_draw ? view_current : -1;
    var _actor_key = _who == noone ? "" : string(_view) + ":" + string(_who);
    if (_phase == "pre-draw-authoritative") {
        if (_c.frame.drawStage == 0) { _c.drawSequence += 1; _c.frame.drawId = _c.drawSequence; }
        _c.frame.expectedViews = [];
        if (!view_enabled) array_push(_c.frame.expectedViews, 0);
        else for (var _v = 0; _v < 8; ++_v)
            if (view_visible[_v]) array_push(_c.frame.expectedViews, _v);
    }
    var _issues = camera_qa_phase_apply(_c.frame, _phase, _draw_context, _view, _actor_key);
    for (var _e = 0; _e < array_length(_issues); ++_e) camera_qa_issue(_issues[_e], _phase);
    variable_struct_set(_c.phaseCounts, _phase, camera_qa_value(_c.phaseCounts, _phase, 0) + 1);
    if (_phase == "root-begin" || _phase == "root-end") camera_qa_discover();
    var _sample = {phase:_phase, room:room_get_name(room), roomGeneration:_generation,
        roomSize:[room_width, room_height], simulationFrame:_q.frame,
        tickId:timing_tick_id(), outerId:_outer, drawId:_c.frame.drawId,
        generatedDrawFrames:_t.drawn_frames, isTick:timing_is_tick(),
        elapsedUs:get_timer() - _c.startUs, accumulatorUs:_t.accumulator_us,
        alpha:clamp(_t.accumulator_us * TCC_SIM_HZ / 1000000, 0, 1),
        renderCap:global.renderfps, nativeOuterHz:game_get_speed(gamespeed_fps),
        drawScheduled:_t.draw_frame, drawContext:_ordinary_draw,
        suppliedDrawContext:_draw_context, inputMask:_q.mask, qaStarted:_q.started,
        nativeEventType:event_type, nativeEventNumber:event_number,
        configuredViews:undefined, actualDraw:undefined, actors:[], phaseIssues:_issues};
    if (_ordinary_draw) _sample.actualDraw = camera_qa_draw_camera(_phase);
    else _sample.configuredViews = camera_qa_configured_views();
    if (_phase == "actor-draw") {
        if (_who == noone || !instance_exists(_who)) camera_qa_issue("actor-draw-without-active-actor", _actor_key);
        else if (camera_qa_role(_who.object_index) == "unsupported") camera_qa_issue("unsupported-actor-draw", _actor_key);
        else {
            var _state = camera_qa_actor(_who); _state.snapshotOnly = !_ordinary_draw;
            _state.drawEntryObserved = _ordinary_draw; array_push(_sample.actors, _state);
        }
    } else if (!_ordinary_draw) {
        for (var _a = 0; _a < array_length(_c.selected); ++_a)
            array_push(_sample.actors, camera_qa_actor(_c.selected[_a]));
    }
    array_push(_c.samples, _sample);
}

function camera_qa_summary() {
    if (!camera_qa_boot()) return undefined;
    var _q = global.tcc_qa, _c = _q.camera_observation;
    if (_c.invalid != "") return {schemaVersion:2, verdict:"unassessed", invalid:_c.invalid, spec:_c.spec};
    var _tail = undefined;
    if (!is_undefined(_c.frame)) _tail = {outer:_c.frame.outer, generation:_c.frame.generation,
        expectedDraw:_c.frame.expectedDraw, drawStage:_c.frame.drawStage,
        issuesIfClosedNow:camera_qa_phase_close(_c.frame)};
    return {schemaVersion:2, format:"tcc.camera-observation", verdict:"unassessed",
        sourceIdentity:camera_qa_value(_q.spec, "identity", undefined),
        inputClock:TCC_INPUT_CLOCK, simulationHz:TCC_SIM_HZ, renderCap:_q.fps,
        spec:_c.spec, recordingStarted:_c.recording, startTick:_c.startTick, startOuter:_c.startOuter,
        startSimulationFrame:_c.startSimulationFrame, deferredInitialSamples:_c.deferredSamples,
        startQaStarted:_c.startQaStarted, startRoomGeneration:_c.startRoomGeneration, startReason:_c.startReason,
        limits:{maxSamples:_c.maxSamples, maxActors:_c.maxActors, maxIdentities:_c.maxIdentities,
            maxCandidates:_c.maxCandidates, maxIssues:_c.maxIssues},
        samplesTruncated:_c.samplesTruncated, droppedSamples:_c.droppedSamples,
        identitiesTruncated:_c.identitiesTruncated, selectionTruncated:_c.selectionTruncated,
        discoveryTruncated:_c.discoveryTruncated, issuesTruncated:_c.issuesTruncated,
        phaseCounts:_c.phaseCounts, closedOuterFrames:_c.closedFrames, pendingTail:_tail,
        issueCount:_c.issueCount, issues:_c.issues, readFailures:_c.readFailures, matrixFailures:_c.matrixFailures,
        identities:_c.identities, samples:_c.samples, fixture:_c.fixture,
        fixtureStarts:_c.fixtureStarts, fixtureStartsTruncated:_c.fixtureStartsTruncated,
        limitations:["first complete fixture Begin preserves actual pre-input qaStarted/frame/scene stamps",
            "pending final End/Draw phases remain explicit; no missing sample is synthesized",
            "configured camera reads outside Draw are not applied camera matrices",
            "first-use camera matrices are provisional until native viewport use is observed",
            "snapshotOnly actors do not prove that their default Draw executed",
            "actor bounds and camera rectangles do not establish native pixels, occlusion, or clipping",
            "retained unavailable IDs do not distinguish destruction from a failed inactive read",
            "native acceptance requires real captures and phase-aware cross-cap comparison"]};
}

// Optional diagnostic authoring only. Call during r_gameplay_qa creation, before
// fallback calibration geometry/player creation. No source room/resource changes,
// camera callbacks, fake follower instances, ammo grants, player repositioning,
// input generation, collision dispatch, or completion are performed.
function camera_qa_fixture(_spec = undefined) {
    if (!qa_active() || !is_struct(_spec) || !variable_struct_exists(_spec, "cameraFixture")) return false;
    try {
        if (!camera_qa_boot() || global.tcc_qa.camera_observation.invalid != "")
            throw "Camera fixture requires valid cameraObservation";
        var _q = global.tcc_qa, _c = _q.camera_observation, _f = _spec.cameraFixture;
        if (!is_struct(_f) || room != r_gameplay_qa || !_q.running || _q.finished
            || !variable_global_exists("tcc_timing")
            || qa_local_multiplayer() || (_q.started && !_q.recovery_pending)
            || variable_struct_exists(_spec, "timingProbe") || variable_struct_exists(_spec, "challenge")
            || variable_struct_exists(_spec, "specialIndex") || variable_struct_exists(_spec, "levelSelect")
            || camera_qa_value(_spec, "fixture", "default") != "default")
            throw "Camera fixture requires isolated SP calibration room creation";
        if (instance_number(o_player) != 0 || instance_number(o_playerMU) != 0
            || instance_number(o_playerdead) != 0 || instance_number(o_whiteblock) != 0
            || instance_number(o_smoothcamera) != 0 || instance_number(o_gun) != 0
            || instance_number(o_torch) != 0 || instance_number(o_portalpurpleopen) != 0
            || instance_number(o_portalpurpleclosed) != 0)
            throw "Camera fixture cannot replace an existing gameplay world";
        var _follow = camera_qa_value(_f, "follow", "direct"), _geometry = camera_qa_value(_f, "geometry", "flat");
        if (!array_contains(["direct", "smooth"], _follow) || !array_contains(["flat", "steps"], _geometry))
            throw "Camera fixture invalid follow/geometry";
        var _portals = camera_qa_boolean(_f, "portals", false), _wrap = camera_qa_boolean(_f, "wrap", false);
        var _gun = camera_qa_boolean(_f, "gun", false), _zero_g = camera_qa_boolean(_f, "zeroGravityCycle", false);
        var _torches = camera_qa_integer(_f, "torches", 0, 0, 3);
        var _margin = _portals ? 768 : 64;
        var _start_x = camera_qa_integer(_f, "startX", 1536, _margin, room_width - 768);
        var _floor_y = camera_qa_integer(_f, "floorY", 7000, 256, room_height - 64);
        if (!view_enabled || !view_visible[0] || view_camera[0] == -1)
            throw "Camera fixture requires existing calibration viewport zero";
        var _cam = view_camera[0];
        // Validate all input and prerequisites before the first created actor.
        // Use this room's existing camera: no extra dynamic camera to leak.
        var _before = camera_qa_camera(_cam);
        if (!_before.available) throw "Camera fixture cannot read its existing camera";
        var _floor = timing_create_depth(0, _floor_y, 0, o_whiteblock,
            {image_xscale:room_width / 32, image_yscale:1});
        if (_geometry == "steps") {
            timing_create_depth(_start_x + 320, _floor_y - 64, 0, o_whiteblock,
                {image_xscale:4, image_yscale:2});
            timing_create_depth(_start_x + 512, _floor_y - 128, 0, o_whiteblock,
                {image_xscale:4, image_yscale:4});
        }
        var _player = timing_create_depth(_start_x, _floor_y - 28, 1, o_player);
        var _pickup_ids = [];
        if (_gun) array_push(_pickup_ids, timing_create_depth(_start_x + 128, _floor_y - 32, 0, o_gun));
        // All torches exist before input. Their real Create resets torchcount;
        // their real collision must collect them and create the third-torch fire.
        for (var _i = 0; _i < _torches; ++_i)
            array_push(_pickup_ids, timing_create_depth(_start_x + 256 + _i * 128, _floor_y - 32, 0, o_torch));
        if (_zero_g) {
            array_push(_pickup_ids, timing_create_depth(_start_x + 576, _floor_y - 32, 0, o_zerogravity));
            array_push(_pickup_ids, timing_create_depth(_start_x + 640, _floor_y - 32, 0, o_gravity15));
        }
        if (_portals) {
            array_push(_pickup_ids, timing_create_depth(_start_x + 704, _floor_y - 32, 0, o_portalpurpleopen));
            array_push(_pickup_ids, timing_create_depth(_start_x - 704, _floor_y - 32, 0, o_portalpurpleclosed));
        }
        if (_wrap) {
            array_push(_pickup_ids, timing_create_depth(0, _floor_y - 32, 0, o_blockwrapleft));
            array_push(_pickup_ids, timing_create_depth(room_width - 32, _floor_y - 32, 0, o_blockwrapright));
        }
        var _helper = noone;
        if (_follow == "smooth") _helper = timing_create_depth(0, 0, -100, o_smoothcamera);
        // Setup-only changes inside the diagnostic room. Direct uses its exact
        // default descriptor; smooth preserves production r_challengelevel's
        // authored -2 sentinel rather than silently turning it into -1.
        camera_set_view_target(_cam, _follow == "smooth" ? o_smoothcamera : o_player);
        camera_set_view_border(_cam, _follow == "smooth" ? 512 : 32, _follow == "smooth" ? 384 : 32);
        camera_set_view_speed(_cam, _follow == "smooth" ? -2 : -1, _follow == "smooth" ? -2 : -1);
        _c.fixture = {kind:"native-camera-calibration-only", follow:_follow, geometry:_geometry,
            start:[_start_x, _floor_y - 28], floorY:_floor_y, gun:_gun, torches:_torches,
            portals:_portals, wrap:_wrap, zeroGravityCycle:_zero_g,
            cameraBefore:_before, cameraAfter:camera_qa_camera(_cam),
            policies:{directSource:"rooms/r_gameplay_qa/r_gameplay_qa.yy",
                smoothSource:"rooms/r_challengelevel/r_challengelevel.yy; objects/o_smoothcamera/Step_0.gml",
                smoothInitialPosition:[0, 0], bigLevelPerfSettings:global.biglevelperfsettings}};
        if (array_length(_c.fixtureStarts) < 16) array_push(_c.fixtureStarts,
            {tickId:timing_tick_id(), outerId:timing_render_id(), roomGenerationAtCreation:global.tcc_timing.room_generation,
                simulationFrame:_q.frame, deaths:_q.deaths, recoveryPending:_q.recovery_pending,
                playerId:_player, helperId:_helper, floorId:_floor, pickupIds:_pickup_ids});
        else _c.fixtureStartsTruncated = true;
        return true;
    } catch (_error) {
        qa_finish("invalid", "Camera QA fixture: " + camera_qa_value(_error, "message", string(_error)));
        return true;
    }
}
