/// Opt-in, diagnostic-only default native camera-follow probe.
/// Main owns registration/integration. No production camera callback is changed.
/// setup: once in a complete logical Begin, after normal default player/floor.
/// sample: root/pre/post boundaries; true ONLY in ordinary per-view Draw.
/// summary: export under a diagnostic field, never as a gameplay completion.
/// The sprite-less dummy's gated Step owns all later pose/lifecycle stimuli.

// BEGIN PURE REQUEST VALIDATION (also executed by cache-only offline checks).
function camera_follow_qa_value(_record, _name, _fallback) {
    return is_struct(_record) && variable_struct_exists(_record, _name)
        ? variable_struct_get(_record, _name) : _fallback;
}

function camera_follow_qa_keys(_record, _allowed, _name) {
    if (!is_struct(_record)) throw "Camera follow probe requires struct " + _name;
    var _keys = variable_struct_get_names(_record);
    for (var _i = 0; _i < array_length(_keys); ++_i)
        if (!array_contains(_allowed, _keys[_i])) throw "Camera follow probe unknown " + _name + "." + _keys[_i];
}

function camera_follow_qa_number(_value, _name, _minimum, _maximum, _integer = false) {
    if (!is_real(_value) || is_bool(_value) || is_nan(_value) || is_infinity(_value)
        || _value < _minimum || _value > _maximum || (_integer && _value != floor(_value)))
        throw "Camera follow probe invalid " + _name;
    return _value;
}

function camera_follow_qa_tuple(_value, _name, _length, _minimum, _maximum) {
    if (!is_array(_value) || array_length(_value) != _length)
        throw "Camera follow probe invalid " + _name;
    for (var _i = 0; _i < _length; ++_i)
        camera_follow_qa_number(_value[_i], _name, _minimum, _maximum);
    return _value;
}

function camera_follow_qa_validate(_spec) {
    var _out = {enabled:false, valid:true, error:"", descriptor:undefined};
    if (!is_struct(_spec) || !variable_struct_exists(_spec, "cameraFollowProbe")) return _out;
    _out.enabled = true;
    try {
        if (camera_follow_qa_value(_spec, "room", "") != "r_gameplay_qa"
            || camera_follow_qa_value(_spec, "fixture", "default") != "default"
            || camera_follow_qa_value(_spec, "mode", "replay") != "replay"
            || camera_follow_qa_value(_spec, "actor", "") != ""
            || camera_follow_qa_value(_spec, "inputClock", "") != TCC_INPUT_CLOCK
            || camera_follow_qa_value(_spec, "simulationHz", 0) != TCC_SIM_HZ)
            throw "Camera follow probe requires simulation-60 SP default calibration replay";
        var _incompatible = ["cameraFixture", "timingProbe", "timingScenario", "nativeActorProbe", "slopeProbe",
            "challenge", "specialIndex", "levelSelect", "route", "routeStartFrame", "fpsOverrides", "retryFrames",
            "artPreview", "galleryPreview"];
        for (var _k = 0; _k < array_length(_incompatible); ++_k)
            if (variable_struct_exists(_spec, _incompatible[_k]))
                throw "Camera follow probe incompatible " + _incompatible[_k];
        camera_follow_qa_number(camera_follow_qa_value(_spec, "fps", undefined), "fps", 30, 1000, true);
        camera_follow_qa_number(camera_follow_qa_value(_spec, "seed", 0), "seed", 0, 2147483647, true);
        var _limit = camera_follow_qa_number(camera_follow_qa_value(_spec, "maxFrames", undefined), "maxFrames", 2, 1200, true);
        camera_follow_qa_number(camera_follow_qa_value(_spec, "traceEvery", 1), "traceEvery", 1, 1, true);
        if (camera_follow_qa_value(_spec, "expect", "") != "frames")
            throw "Camera follow probe requires diagnostic frame-limit observation";
        if (!is_string(camera_follow_qa_value(_spec, "output", undefined))
            || !is_string(camera_follow_qa_value(_spec, "saveRoot", undefined)))
            throw "Camera follow probe requires QA output/saveRoot";
        var _inputs = camera_follow_qa_value(_spec, "inputs", undefined), _prior = -1;
        if (!is_array(_inputs) || array_length(_inputs) < 1 || array_length(_inputs) > _limit)
            throw "Camera follow probe invalid inputs";
        for (var _i = 0; _i < array_length(_inputs); ++_i) {
            var _input = _inputs[_i];
            camera_follow_qa_keys(_input, ["frame", "mask"], "input");
            var _frame = camera_follow_qa_number(camera_follow_qa_value(_input, "frame", undefined), "input.frame", 0, _limit - 1, true);
            camera_follow_qa_number(camera_follow_qa_value(_input, "mask", undefined), "input.mask", 0, 63, true);
            if (_frame <= _prior || (_i == 0 && _frame != 0)) throw "Camera follow probe unordered inputs";
            _prior = _frame;
        }
        var _p = _spec.cameraFollowProbe;
        camera_follow_qa_keys(_p, ["schemaVersion", "caseId", "camera", "targets", "driverIndex", "lifecycle", "maxSamples", "maxEvents", "maxIssues"], "descriptor");
        camera_follow_qa_number(camera_follow_qa_value(_p, "schemaVersion", undefined), "schemaVersion", 1, 1, true);
        var _case = camera_follow_qa_value(_p, "caseId", undefined);
        if (!is_string(_case) || string_length(_case) < 1 || string_length(_case) > 80)
            throw "Camera follow probe invalid caseId";
        camera_follow_qa_number(camera_follow_qa_value(_p, "maxSamples", 24000), "maxSamples", 64, 50000, true);
        camera_follow_qa_number(camera_follow_qa_value(_p, "maxEvents", 12000), "maxEvents", 64, 12000, true);
        camera_follow_qa_number(camera_follow_qa_value(_p, "maxIssues", 128), "maxIssues", 16, 256, true);
        var _camera = camera_follow_qa_value(_p, "camera", undefined);
        camera_follow_qa_keys(_camera, ["view", "border", "speed", "angle", "targetMode", "targetIndex"], "camera");
        var _view = camera_follow_qa_tuple(camera_follow_qa_value(_camera, "view", undefined), "camera.view", 4, -32768, 32768);
        if (_view[2] <= 0 || _view[3] <= 0) throw "Camera follow probe nonpositive view size";
        camera_follow_qa_tuple(camera_follow_qa_value(_camera, "border", undefined), "camera.border", 2, 0, 32768);
        var _speed = camera_follow_qa_tuple(camera_follow_qa_value(_camera, "speed", undefined), "camera.speed", 2, -2, 1024);
        for (var _s = 0; _s < 2; ++_s)
            if (_speed[_s] < 0 && _speed[_s] != -1 && _speed[_s] != -2)
                throw "Camera follow probe unsupported negative speed";
        camera_follow_qa_number(camera_follow_qa_value(_camera, "angle", undefined), "camera.angle", -360, 360);
        var _mode = camera_follow_qa_value(_camera, "targetMode", undefined);
        if (!array_contains(["none", "asset", "instance"], _mode)) throw "Camera follow probe invalid targetMode";
        var _targets = camera_follow_qa_value(_p, "targets", undefined);
        if (!is_array(_targets) || array_length(_targets) > 8) throw "Camera follow probe invalid targets";
        var _labels = [], _states = [];
        for (var _t = 0; _t < array_length(_targets); ++_t) {
            var _target = _targets[_t];
            camera_follow_qa_keys(_target, ["label", "initiallyPresent", "poses"], "target");
            var _label = camera_follow_qa_value(_target, "label", undefined);
            if (!is_string(_label) || string_length(_label) < 1 || string_length(_label) > 40 || array_contains(_labels, _label))
                throw "Camera follow probe invalid/duplicate target label";
            array_push(_labels, _label);
            var _initial = camera_follow_qa_value(_target, "initiallyPresent", undefined);
            if (!is_bool(_initial)) throw "Camera follow probe invalid initiallyPresent";
            array_push(_states, _initial ? "active" : "absent");
            var _poses = camera_follow_qa_value(_target, "poses", undefined);
            if (!is_array(_poses) || array_length(_poses) < 1 || array_length(_poses) > 128)
                throw "Camera follow probe invalid poses";
            _prior = -1;
            for (var _j = 0; _j < array_length(_poses); ++_j) {
                camera_follow_qa_keys(_poses[_j], ["frame", "x", "y"], "pose");
                _frame = camera_follow_qa_number(camera_follow_qa_value(_poses[_j], "frame", undefined), "pose.frame", 0, _limit - 1, true);
                camera_follow_qa_number(camera_follow_qa_value(_poses[_j], "x", undefined), "pose.x", -32768, 32768);
                camera_follow_qa_number(camera_follow_qa_value(_poses[_j], "y", undefined), "pose.y", -32768, 32768);
                if (_frame <= _prior || (_j == 0 && _frame != 0)) throw "Camera follow probe unordered poses";
                _prior = _frame;
            }
        }
        var _count = array_length(_targets), _driver = camera_follow_qa_value(_p, "driverIndex", -1);
        if (_count == 0) {
            if (_driver != -1 || _mode == "instance") throw "Camera follow probe missing target/driver";
        } else {
            camera_follow_qa_number(_driver, "driverIndex", 0, _count - 1, true);
            if (_states[_driver] != "active") throw "Camera follow probe driver must initially exist";
        }
        if (_mode == "instance") {
            var _selected = camera_follow_qa_number(camera_follow_qa_value(_camera, "targetIndex", undefined), "targetIndex", 0, _count - 1, true);
            if (_states[_selected] != "active") throw "Camera follow probe explicit target must initially exist";
        } else if (variable_struct_exists(_camera, "targetIndex")) throw "Camera follow probe targetIndex only for instance target";
        var _lifecycle = camera_follow_qa_value(_p, "lifecycle", []), _keys = [];
        if (!is_array(_lifecycle) || array_length(_lifecycle) > 64) throw "Camera follow probe invalid lifecycle";
        _prior = 0;
        for (var _l = 0; _l < array_length(_lifecycle); ++_l) {
            var _action = _lifecycle[_l];
            camera_follow_qa_keys(_action, ["frame", "targetIndex", "action"], "lifecycle");
            _frame = camera_follow_qa_number(camera_follow_qa_value(_action, "frame", undefined), "lifecycle.frame", 1, _limit - 1, true);
            var _index = camera_follow_qa_number(camera_follow_qa_value(_action, "targetIndex", undefined), "lifecycle.targetIndex", 0, _count - 1, true);
            var _verb = camera_follow_qa_value(_action, "action", undefined), _key = string(_frame) + ":" + string(_index);
            if (!array_contains(["create", "destroy", "deactivate", "activate"], _verb)
                || _frame < _prior || array_contains(_keys, _key) || _index == _driver)
                throw "Camera follow probe ambiguous/unordered lifecycle or driver mutation";
            _prior = _frame;
            array_push(_keys, _key);
            if (_verb == "create" && _states[_index] == "absent") _states[_index] = "active";
            else if (_verb == "destroy" && _states[_index] == "active") _states[_index] = "absent";
            else if (_verb == "deactivate" && _states[_index] == "active") _states[_index] = "inactive";
            else if (_verb == "activate" && _states[_index] == "inactive") _states[_index] = "active";
            else throw "Camera follow probe invalid lifecycle state";
        }
        _out.descriptor = _p;
    } catch (_error) {
        _out.valid = false;
        _out.error = camera_follow_qa_value(_error, "message", string(_error));
    }
    return _out;
}
// END PURE REQUEST VALIDATION.

function camera_follow_qa_active() {
    return qa_active() && variable_struct_exists(global.tcc_qa, "camera_follow_probe")
        && global.tcc_qa.camera_follow_probe.invalid == "";
}

function camera_follow_qa_stamp() {
    return {tickId:timing_tick_id(), outerId:timing_render_id(),
        simulationFrame:global.tcc_qa.frame, isTick:timing_is_tick(),
        drawId:global.tcc_timing.drawn_frames, roomGeneration:global.tcc_timing.room_generation};
}

function camera_follow_qa_issue(_kind, _detail = undefined) {
    var _p = global.tcc_qa.camera_follow_probe;
    _p.issueCount += 1;
    if (array_length(_p.issues) >= _p.maxIssues) { _p.issuesTruncated = true; return; }
    array_push(_p.issues, {kind:_kind, detail:_detail, stamp:camera_follow_qa_stamp()});
}

function camera_follow_qa_event(_kind, _detail) {
    var _p = global.tcc_qa.camera_follow_probe;
    if (array_length(_p.events) >= _p.maxEvents) { _p.eventsTruncated = true; _p.droppedEvents += 1; return; }
    array_push(_p.events, {kind:_kind, detail:_detail, stamp:camera_follow_qa_stamp()});
}

// Each operation retains its own actual native result/error. These queries do
// not classify the camera getter as an asset or choose an instance for it.
function camera_follow_qa_query(_operation, _camera, _ref = undefined) {
    var _record = {operation:_operation, ok:false, value:undefined, error:undefined};
    try {
        switch (_operation) {
            case "camera_get_view_x": _record.value = camera_get_view_x(_camera); break;
            case "camera_get_view_y": _record.value = camera_get_view_y(_camera); break;
            case "camera_get_view_width": _record.value = camera_get_view_width(_camera); break;
            case "camera_get_view_height": _record.value = camera_get_view_height(_camera); break;
            case "camera_get_view_angle": _record.value = camera_get_view_angle(_camera); break;
            case "camera_get_view_border_x": _record.value = camera_get_view_border_x(_camera); break;
            case "camera_get_view_border_y": _record.value = camera_get_view_border_y(_camera); break;
            case "camera_get_view_speed_x": _record.value = camera_get_view_speed_x(_camera); break;
            case "camera_get_view_speed_y": _record.value = camera_get_view_speed_y(_camera); break;
            case "camera_get_view_target": _record.value = camera_get_view_target(_camera); break;
            case "camera_get_update_script": _record.value = camera_get_update_script(_camera); break;
            case "camera_get_view_mat": _record.value = camera_follow_qa_matrix(camera_get_view_mat(_camera)); break;
            case "camera_get_proj_mat": _record.value = camera_follow_qa_matrix(camera_get_proj_mat(_camera)); break;
            case "matrix_get_world": _record.value = camera_follow_qa_matrix(matrix_get(matrix_world)); break;
            case "matrix_get_view": _record.value = camera_follow_qa_matrix(matrix_get(matrix_view)); break;
            case "matrix_get_projection": _record.value = camera_follow_qa_matrix(matrix_get(matrix_projection)); break;
            case "typeof": _record.value = typeof(_ref); break;
            case "string": _record.value = string(_ref); break;
            case "asset_get_type": _record.value = asset_get_type(_ref); break;
            case "object_exists": _record.value = object_exists(_ref); break;
            case "object_get_name": _record.value = object_get_name(_ref); break;
            case "instance_exists": _record.value = instance_exists(_ref); break;
            case "variable_instance_exists(object_index)": _record.value = variable_instance_exists(_ref, "object_index"); break;
            case "ref.object_index": _record.value = _ref.object_index; break;
            case "ref.id": _record.value = _ref.id; break;
            case "ref.x": _record.value = _ref.x; break;
            case "ref.y": _record.value = _ref.y; break;
            default: throw "Unknown camera follow query " + _operation;
        }
        _record.ok = true;
    } catch (_error) {
        _record.error = camera_follow_qa_value(_error, "message", string(_error));
    }
    return _record;
}

function camera_follow_qa_matrix(_value) {
    if (!is_array(_value) || array_length(_value) != 16) throw "Camera follow matrix is not length 16";
    var _copy = [];
    for (var _i = 0; _i < 16; ++_i)
        array_push(_copy, camera_follow_qa_number(_value[_i], "native matrix", -power(10, 100), power(10, 100)));
    return _copy;
}

function camera_follow_qa_reference(_ref) {
    var _queries = [], _operations = ["typeof", "string", "asset_get_type", "object_exists", "object_get_name",
        "instance_exists", "variable_instance_exists(object_index)", "ref.object_index", "ref.id", "ref.x", "ref.y"];
    for (var _i = 0; _i < array_length(_operations); ++_i)
        array_push(_queries, camera_follow_qa_query(_operations[_i], -1, _ref));
    var _matches = [], _known = [];
    if (camera_follow_qa_active()) {
        var _records = global.tcc_qa.camera_follow_probe.targets;
        for (var _t = 0; _t < array_length(_records); ++_t)
            array_push(_matches, {targetIndex:_t, latestInstanceId:_records[_t].instanceId,
                equalsLatestInstance:_ref == _records[_t].instanceId});
        for (var _k = 0; _k < array_length(_records); ++_k)
            for (var _j = 0; _j < array_length(_records[_k].allInstanceIds); ++_j) {
                var _id = _records[_k].allInstanceIds[_j];
                array_push(_known, {targetIndex:_k, incarnationIndex:_j,
                    actualInstanceId:_id, equalsActualInstance:_ref == _id});
            }
    }
    return {rawRef:_ref, equalsDummyAsset:_ref == o_camera_follow_qa_target,
        equalsNoTarget:_ref == -1, operations:_queries, registryEqualityTests:_matches,
        actualInstanceEqualityTests:_known,
        interpretation:"raw native query outcomes; no inferred first-instance identity"};
}

function camera_follow_qa_camera(_camera) {
    var _operations = ["camera_get_view_x", "camera_get_view_y", "camera_get_view_width", "camera_get_view_height",
        "camera_get_view_angle", "camera_get_view_border_x", "camera_get_view_border_y", "camera_get_view_speed_x",
        "camera_get_view_speed_y", "camera_get_view_target", "camera_get_update_script",
        "camera_get_view_mat", "camera_get_proj_mat"], _queries = [], _target = undefined;
    for (var _i = 0; _i < array_length(_operations); ++_i) {
        var _query = camera_follow_qa_query(_operations[_i], _camera);
        array_push(_queries, _query);
        if (_operations[_i] == "camera_get_view_target" && _query.ok) _target = camera_follow_qa_reference(_query.value);
    }
    return {cameraId:_camera, operations:_queries, targetGetter:_target,
        matrixContext:"configured camera properties; not active/applied matrix_get state"};
}

function camera_follow_qa_pose(_index, _frame) {
    var _poses = global.tcc_qa.camera_follow_probe.spec.targets[_index].poses, _selected = _poses[0];
    for (var _i = 1; _i < array_length(_poses); ++_i) {
        if (_poses[_i].frame > _frame) break;
        _selected = _poses[_i];
    }
    return _selected;
}

function camera_follow_qa_create(_index, _frame) {
    var _p = global.tcc_qa.camera_follow_probe, _pose = camera_follow_qa_pose(_index, _frame);
    var _id = timing_create_depth(_pose.x, _pose.y, -999, o_camera_follow_qa_target,
        {camera_follow_qa_index:_index, camera_follow_qa_token:_p.token});
    _p.targets[_index].instanceId = _id;
    _p.targets[_index].declaredState = "active";
    _p.targets[_index].incarnation += 1;
    array_push(_p.targets[_index].allInstanceIds, _id);
    camera_follow_qa_event("create", {targetIndex:_index, instanceId:_id, pose:_pose,
        relativeTick:_frame, incarnation:_p.targets[_index].incarnation});
    return _id;
}

function camera_follow_qa_setup(_spec) {
    var _validation = camera_follow_qa_validate(_spec);
    if (!_validation.enabled) return false;
    if (!qa_active()) return true;
    var _q = global.tcc_qa;
    if (variable_struct_exists(_q, "camera_follow_probe")) return true;
    if (!_validation.valid) {
        _q.camera_follow_probe = {invalid:_validation.error, spec:_spec.cameraFollowProbe};
        _q.invalid = _validation.error;
        return true;
    }
    try {
        // All pure validation AND all room/clock prerequisites precede writes.
        if (room != r_gameplay_qa || !_q.running || _q.finished || _q.preparing
            || !variable_global_exists("tcc_timing") || !timing_is_tick()
            || !view_enabled || !view_visible[0] || view_camera[0] == -1
            || instance_number(o_player) != 1 || instance_number(o_whiteblock) < 1
            || instance_number(o_playerMU) != 0 || instance_number(o_playerdead) != 0
            || instance_number(o_camera_follow_qa_target) != 0)
            throw "Camera follow probe needs full logical Begin in intact default SP diagnostic room";
        var _cam = view_camera[0], _callback = camera_follow_qa_query("camera_get_update_script", _cam);
        if (!_callback.ok || _callback.value != -1)
            throw "Camera follow probe requires unchanged default native follow callback";
        var _before = camera_follow_qa_camera(_cam);
        for (var _i = 0; _i < array_length(_before.operations); ++_i)
            if (!_before.operations[_i].ok
                && !array_contains(["camera_get_view_mat", "camera_get_proj_mat"], _before.operations[_i].operation))
                throw "Camera follow probe cannot read existing camera descriptor";
        // First-use matrix errors remain exact observations; they must not
        // prevent probing the native first-use behavior being investigated.
        var _f = _validation.descriptor;
        _q.camera_follow_probe = {invalid:"", schemaVersion:1, spec:_f, setupTick:timing_tick_id(),
            setupOuter:timing_render_id(), setupSimulationFrame:_q.frame, startUs:get_timer(),
            token:string(global.tcc_timing.room_generation) + ":" + string(timing_tick_id()),
            cameraId:_cam, targets:[], setupTargetRef:undefined, cameraBefore:_before, cameraAfter:undefined,
            maxSamples:camera_follow_qa_value(_f, "maxSamples", 24000), maxEvents:camera_follow_qa_value(_f, "maxEvents", 12000),
            maxIssues:camera_follow_qa_value(_f, "maxIssues", 128), samples:[], events:[], issues:[],
            samplesTruncated:false, eventsTruncated:false, issuesTruncated:false,
            droppedSamples:0, droppedEvents:0, issueCount:0, phaseCounts:{}, phaseFrame:undefined,
            closedOuterFrames:0, cameraUses:[], lifecycleCursor:0, driverLastTick:-1, ready:true};
        var _p = _q.camera_follow_probe;
        for (var _t = 0; _t < array_length(_f.targets); ++_t)
            array_push(_p.targets, {label:_f.targets[_t].label, targetIndex:_t,
                instanceId:noone, allInstanceIds:[], incarnation:0, declaredState:"absent"});
        for (var _a = 0; _a < array_length(_f.targets); ++_a)
            if (_f.targets[_a].initiallyPresent) camera_follow_qa_create(_a, 0);
        var _c = _f.camera, _target = -1;
        if (_c.targetMode == "asset") _target = o_camera_follow_qa_target;
        else if (_c.targetMode == "instance") _target = _p.targets[_c.targetIndex].instanceId;
        _p.setupTargetRef = _target;
        // The ONLY camera setters in this resource: opt-in setup, never a
        // render hook or follow callback. Native automatic following stays on.
        camera_set_view_size(_cam, _c.view[2], _c.view[3]);
        camera_set_view_pos(_cam, _c.view[0], _c.view[1]);
        camera_set_view_angle(_cam, _c.angle);
        camera_set_view_border(_cam, _c.border[0], _c.border[1]);
        camera_set_view_speed(_cam, _c.speed[0], _c.speed[1]);
        camera_set_view_target(_cam, _target);
        _p.cameraAfter = camera_follow_qa_camera(_cam);
        camera_follow_qa_event("setup", {camera:_c, suppliedTarget:camera_follow_qa_reference(_target),
            actualRoomSize:[room_width, room_height], normalPlayerId:instance_find(o_player, 0),
            normalFloorCount:instance_number(o_whiteblock), existingCameraReused:true});
    } catch (_error) {
        var _message = camera_follow_qa_value(_error, "message", string(_error));
        if (!variable_struct_exists(_q, "camera_follow_probe")) _q.camera_follow_probe = {invalid:_message, spec:_validation.descriptor};
        else _q.camera_follow_probe.invalid = _message;
        _q.invalid = _message;
    }
    return true;
}

function camera_follow_qa_target_initialize() {
    if (!camera_follow_qa_active() || !variable_instance_exists(id, "camera_follow_qa_index")
        || !variable_instance_exists(id, "camera_follow_qa_token")
        || camera_follow_qa_token != global.tcc_qa.camera_follow_probe.token) {
        instance_destroy(); return;
    }
    camera_follow_qa_last_tick = -1;
    camera_follow_qa_step_count = 0;
    camera_follow_qa_birth_tick = timing_tick_id();
    camera_follow_qa_birth_outer = timing_render_id();
    sprite_index = -1; mask_index = -1; image_speed = 0;
    speed = 0; gravity = 0; friction = 0;
    visible = false; solid = false;
}

function camera_follow_qa_target_step() {
    if (!camera_follow_qa_active() || !global.tcc_qa.running || global.tcc_qa.finished) return;
    var _p = global.tcc_qa.camera_follow_probe, _tick = timing_tick_id();
    if (camera_follow_qa_token != _p.token) return;
    if (!timing_is_tick()) { camera_follow_qa_issue("target-step-off-tick", id); return; }
    if (camera_follow_qa_last_tick == _tick) { camera_follow_qa_issue("duplicate-target-step", id); return; }
    camera_follow_qa_last_tick = _tick;
    camera_follow_qa_step_count += 1;
    var _frame = _tick - _p.setupTick;
    // Only the permanent ordinary-Step driver coordinates lifecycle; camera
    // asset follow includes it as a normal candidate. No hidden controller is
    // silently excluded from the asset's candidate set.
    if (camera_follow_qa_index == camera_follow_qa_value(_p.spec, "driverIndex", -1) && _p.driverLastTick != _tick) {
        _p.driverLastTick = _tick;
        var _actions = camera_follow_qa_value(_p.spec, "lifecycle", []);
        while (_p.lifecycleCursor < array_length(_actions) && _actions[_p.lifecycleCursor].frame <= _frame) {
            var _action = _actions[_p.lifecycleCursor];
            _p.lifecycleCursor += 1;
            if (_action.frame != _frame) camera_follow_qa_issue("missed-lifecycle-tick", _action);
            var _entry = _p.targets[_action.targetIndex], _target = _entry.instanceId;
            if (_action.action == "create") _target = camera_follow_qa_create(_action.targetIndex, _frame);
            else if (_action.action == "destroy") { instance_destroy(_target); _entry.declaredState = "absent"; }
            else if (_action.action == "deactivate") { instance_deactivate_object(_target); _entry.declaredState = "inactive"; }
            else if (_action.action == "activate") { timing_activate_object(_target); _entry.declaredState = "active"; }
            camera_follow_qa_event("lifecycle-dispatch", {request:_action, instanceId:_target,
                relativeTick:_frame, nativeCommit:"ordinary Step event end; observation does not assume immediate commit"});
        }
    }
    var _pose = camera_follow_qa_pose(camera_follow_qa_index, _frame), _before = [x, y];
    x = _pose.x; y = _pose.y;
    camera_follow_qa_event("target-step", {targetIndex:camera_follow_qa_index, instanceId:id,
        relativeTick:_frame, selectedPoseFrame:_pose.frame, before:_before, after:[x,y],
        stepCount:camera_follow_qa_step_count, birthTick:camera_follow_qa_birth_tick,
        birthOuter:camera_follow_qa_birth_outer});
}

function camera_follow_qa_targets_snapshot() {
    var _p = global.tcc_qa.camera_follow_probe, _registered = [], _active = [];
    for (var _i = 0; _i < array_length(_p.targets); ++_i) {
        var _t = _p.targets[_i];
        array_push(_registered, {targetIndex:_i, label:_t.label, declaredState:_t.declaredState,
            incarnation:_t.incarnation, allInstanceIds:_t.allInstanceIds,
            latestReference:camera_follow_qa_reference(_t.instanceId)});
    }
    // Independent complete native enumeration, not a camera target lookup.
    var _count = instance_number(o_camera_follow_qa_target);
    for (var _a = 0; _a < _count; ++_a) {
        var _id = instance_find(o_camera_follow_qa_target, _a);
        var _record = {enumerationIndex:_a, instanceId:_id, reference:camera_follow_qa_reference(_id),
            targetIndex:undefined, stepCount:undefined, lastStepTick:undefined, birthTick:undefined,
            timing:undefined};
        try {
            _record.targetIndex = _id.camera_follow_qa_index;
            _record.stepCount = _id.camera_follow_qa_step_count;
            _record.lastStepTick = _id.camera_follow_qa_last_tick;
            _record.birthTick = _id.camera_follow_qa_birth_tick;
            if (variable_instance_exists(_id, "timing_native")) {
                var _n = _id.timing_native;
                _record.timing = {previous:[_n.previous_x,_n.previous_y], current:[_n.current_x,_n.current_y],
                    start:[_n.start_x,_n.start_y], interpolated:_n.interpolated, held:_n.held};
            }
        } catch (_error) { _record.fieldError = camera_follow_qa_value(_error, "message", string(_error)); }
        array_push(_active, _record);
    }
    return {registry:_registered, activeCount:_count, activeEnumeration:_active,
        enumerationPolicy:"native enumeration order retained; no selected-winner inference"};
}

function camera_follow_qa_sample(_phase, _draw_context = false) {
    if (!camera_follow_qa_active() || !global.tcc_qa.running || global.tcc_qa.finished) return;
    var _q = global.tcc_qa, _p = _q.camera_follow_probe, _t = global.tcc_timing;
    var _phases = ["root-begin", "root-end", "pre-draw-authoritative", "pre-draw-interpolated",
        "view-draw-begin", "view-draw-end", "post-draw-before-restore", "post-draw-restored"];
    if (!is_string(_phase) || !array_contains(_phases, _phase) || !is_bool(_draw_context)) {
        camera_follow_qa_issue("invalid-sample-arguments", {phase:_phase, drawContext:_draw_context}); return;
    }
    var _ordinary = _draw_context && array_contains(["view-draw-begin", "view-draw-end"], _phase);
    if (_ordinary != _draw_context || (array_contains(["view-draw-begin", "view-draw-end"], _phase) && !_draw_context))
        camera_follow_qa_issue("draw-context-mismatch", {phase:_phase, supplied:_draw_context});
    var _outer = timing_render_id(), _generation = _t.room_generation;
    if (is_undefined(_p.phaseFrame) || _p.phaseFrame.outer != _outer || _p.phaseFrame.generation != _generation) {
        if (!is_undefined(_p.phaseFrame)) {
            var _closed = camera_qa_phase_close(_p.phaseFrame);
            for (var _c = 0; _c < array_length(_closed); ++_c) camera_follow_qa_issue(_closed[_c], _p.phaseFrame.outer);
            _p.closedOuterFrames += 1;
        }
        _p.phaseFrame = camera_qa_phase_state(_outer, _generation);
        _p.phaseFrame.expectedDraw = _t.draw_frame;
    }
    if (_phase == "pre-draw-authoritative") {
        _p.phaseFrame.drawId = _t.drawn_frames + 1;
        _p.phaseFrame.expectedViews = [];
        if (!view_enabled) array_push(_p.phaseFrame.expectedViews, 0);
        else for (var _v = 0; _v < 8; ++_v) if (view_visible[_v]) array_push(_p.phaseFrame.expectedViews, _v);
    }
    var _view = _ordinary ? view_current : -1;
    var _issues = camera_qa_phase_apply(_p.phaseFrame, _phase, _draw_context, _view, "");
    for (var _e = 0; _e < array_length(_issues); ++_e) camera_follow_qa_issue(_issues[_e], _phase);
    variable_struct_set(_p.phaseCounts, _phase, camera_follow_qa_value(_p.phaseCounts, _phase, 0) + 1);
    if (array_length(_p.samples) >= _p.maxSamples) { _p.samplesTruncated = true; _p.droppedSamples += 1; return; }
    var _row = {phase:_phase, stamp:camera_follow_qa_stamp(), relativeTick:timing_tick_id() - _p.setupTick,
        qStarted:_q.started, inputMask:_q.mask, room:room_get_name(room), roomSize:[room_width,room_height],
        elapsedUs:get_timer() - _p.startUs, accumulatorUs:_t.accumulator_us,
        renderCap:global.renderfps, nativeOuterHz:game_get_speed(gamespeed_fps),
        drawScheduled:_t.draw_frame, actualDrawContext:_ordinary, suppliedDrawContext:_draw_context,
        configuredCamera:undefined, actualDraw:undefined, targets:camera_follow_qa_targets_snapshot(), phaseIssues:_issues};
    if (!_ordinary) _row.configuredCamera = camera_follow_qa_camera(_p.cameraId);
    else {
        // ONLY ordinary Draw reads applied matrices or active camera. A bad
        // hook flag on Pre/Post Draw cannot manufacture an active Draw sample.
        var _active = camera_get_active(), _used = array_contains(_p.cameraUses, _active);
        var _matrix_queries = [], _ops = ["matrix_get_world", "matrix_get_view", "matrix_get_projection",
            "camera_get_view_mat", "camera_get_proj_mat"];
        for (var _m = 0; _m < array_length(_ops); ++_m)
            array_push(_matrix_queries, camera_follow_qa_query(_ops[_m], _active));
        var _matches = undefined;
        if (_view >= 0 && _view < 8 && _view == floor(_view)) _matches = _active == view_camera[_view];
        _row.actualDraw = {activeCamera:_active, viewport:_view, matchesConfiguredViewport:_matches,
            camera:camera_follow_qa_camera(_active), matrixOperations:_matrix_queries,
            priorViewportUseObserved:_used, matrixValidity:_used ? "prior-viewport-use-observed" : "first-use-provisional"};
        if (_phase == "view-draw-end" && !_used) {
            array_push(_p.cameraUses, _active);
            _row.actualDraw.matrixValidity = "first-viewport-use-completed";
        }
    }
    array_push(_p.samples, _row);
}

function camera_follow_qa_summary() {
    if (!qa_active() || !variable_struct_exists(global.tcc_qa, "camera_follow_probe")) return undefined;
    var _q = global.tcc_qa, _p = _q.camera_follow_probe;
    if (_p.invalid != "") return {format:"tcc.camera-follow-probe", schemaVersion:1,
        diagnosticOnly:true, verdict:"unassessed", invalid:_p.invalid, spec:_p.spec};
    var _tail = undefined;
    if (!is_undefined(_p.phaseFrame)) _tail = {outer:_p.phaseFrame.outer,
        expectedDraw:_p.phaseFrame.expectedDraw, drawStage:_p.phaseFrame.drawStage,
        issuesIfClosedNow:camera_qa_phase_close(_p.phaseFrame)};
    return {format:"tcc.camera-follow-probe", schemaVersion:1, diagnosticOnly:true,
        verdict:"unassessed", invalid:"", inputClock:TCC_INPUT_CLOCK, simulationHz:TCC_SIM_HZ,
        renderCap:_q.fps, sourceIdentity:camera_follow_qa_value(_q.spec, "identity", undefined),
        spec:_p.spec, setupTick:_p.setupTick, setupOuter:_p.setupOuter, setupSimulationFrame:_p.setupSimulationFrame,
        cameraId:_p.cameraId, suppliedTarget:camera_follow_qa_reference(_p.setupTargetRef),
        cameraBefore:_p.cameraBefore, cameraAfter:_p.cameraAfter,
        phaseCounts:_p.phaseCounts, closedOuterFrames:_p.closedOuterFrames, pendingTail:_tail,
        samplesTruncated:_p.samplesTruncated, eventsTruncated:_p.eventsTruncated, issuesTruncated:_p.issuesTruncated,
        droppedSamples:_p.droppedSamples, droppedEvents:_p.droppedEvents, issueCount:_p.issueCount,
        limits:{maxSamples:_p.maxSamples,maxEvents:_p.maxEvents,maxIssues:_p.maxIssues},
        lifecycleDispatched:_p.lifecycleCursor, finalTargets:camera_follow_qa_targets_snapshot(),
        issues:_p.issues, events:_p.events, samples:_p.samples,
        limitations:["diagnostic target poses are stimuli, never normal-input player completion evidence",
            "permanent same-object driver is included in native asset-follow candidates",
            "target reference operation errors are retained individually and may be expected native outcomes",
            "native camera target getter is not interpreted as an instance selection",
            "dummy has no sprite, collision mask, hsp/vsp or native speed; existing interpolation policy does not interpolate it",
            "lifecycle commits and first Step timing are observed, not inferred from dispatch",
            "first camera matrix use is provisional until an actual ordinary viewport Draw ends",
            "root/pre/post camera matrix properties do not establish active/applied Draw matrices",
            "final missing Draw phases stay in pendingTail; no synthetic rows or native PASS verdict"]};
}
