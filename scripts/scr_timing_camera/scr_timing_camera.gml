/// Default target following runs once per fixed gameplay tick. Custom camera
/// callbacks retain ownership; diagnostic requests can select native following.
function timing_camera_enabled() {
    if (!variable_global_exists("tcc_timing") || global.tcc_timing.first) return false;
    if (TCC_GAMEPLAY_QA && qa_active()) {
        var _q = global.tcc_qa;
        if (is_struct(qa_value(_q, "camera_follow_pending_spec", undefined))) return false;
        var _enabled = qa_value(_q.spec, "manualCameraCandidate", undefined);
        if (!is_undefined(_enabled)) return is_bool(_enabled) && _enabled;
        // Existing native-follow diagnostics stay baseline unless explicitly enabled.
        if (is_struct(qa_value(_q.spec, "cameraFollowProbe", undefined))
            || is_struct(qa_value(_q.spec, "cameraFixture", undefined))) return false;
    }
    return true;
}

function timing_camera_native_disabled() {
    // Native Draw callbacks may run between gameplay ticks. Target following
    // already happened once in the real End Step, using authoritative poses.
}

function timing_camera_axis(_origin, _size, _border, _speed, _target, _room_size) {
    _border = min(_border, _size / 2);
    var _destination = _origin;
    if (_target < _origin + _border) _destination = floor(_target - _border);
    else if (_target > _origin + _size - _border)
        _destination = floor(_target - _size + _border);
    var _moved = _speed < 0 ? _destination
        : _origin + clamp(_destination - _origin, -_speed, _speed);
    return min(max(_moved, 0), _room_size - _size);
}

function timing_camera_current(_camera) {
    if (!view_enabled) return false;
    for (var _v = 0; _v < 8; ++_v)
        if (view_visible[_v] && view_camera[_v] == _camera) return true;
    return false;
}

function timing_camera_matrix_copy(_matrix) {
    var _copy = [];
    for (var _m = 0; _m < 16; ++_m) array_push(_copy, _matrix[_m]);
    return _copy;
}

function timing_camera_restore() {
    if (!variable_global_exists("tcc_timing")) return;
    var _entries = global.tcc_timing.cameras;
    for (var _i = 0; _i < array_length(_entries); ++_i) {
        var _c = _entries[_i];
        if (!_c.interpolated) continue;
        // Visibility, viewport reassignment and a new update callback do not
        // transfer our temporary Draw transform to the next gameplay frame.
        // A destroyed camera has no state to restore; native handle queries
        // distinguish that case without guessing from viewport attachment.
        try {
            var _matrix = camera_get_view_mat(_c.camera);
            if (is_array(_matrix) && array_length(_matrix) == 16) {
                camera_set_view_pos(_c.camera, _c.saved_x, _c.saved_y);
                camera_set_view_mat(_c.camera, timing_camera_matrix_copy(_c.saved_view_matrix));
                // Interpolation changes only the view. Leave projection with
                // the native render surface: feeding its getter back into the
                // setter flips the Y axis on the measured macOS VM runner.
            }
            _c.interpolated = false;
        } catch (_error) {
            if (qa_active()) global.tcc_qa.invalid = "Camera Draw restoration failed: "
                + qa_value(_error, "message", string(_error));
        }
    }
}

function timing_camera_end_step() {
    if (!timing_camera_enabled() || !timing_is_tick() || !view_enabled) return;
    var _t = global.tcc_timing, _seen = [];
    for (var _v = 0; _v < 8; ++_v) {
        if (!view_visible[_v]) continue;
        var _camera = view_camera[_v];
        if (_camera == -1 || array_contains(_seen, _camera)) continue;
        array_push(_seen, _camera);
        var _callback = camera_get_update_script(_camera);
        if (_callback != -1 && _callback != timing_camera_native_disabled) continue;
        var _target = camera_get_view_target(_camera);
        // -1 is the camera sentinel, even though GML's instance_exists(-1)
        // and dot queries can address self. Inactive readable IDs also wait.
        var _no_target = _target == -1;
        if (_no_target && _callback == -1) continue;
        var _x = camera_get_view_x(_camera), _y = camera_get_view_y(_camera);
        var _w = camera_get_view_width(_camera), _h = camera_get_view_height(_camera);
        var _angle = camera_get_view_angle(_camera), _entry = undefined;
        for (var _i = 0; _i < array_length(_t.cameras); ++_i)
            if (_t.cameras[_i].camera == _camera) { _entry = _t.cameras[_i]; break; }
        var _new = is_undefined(_entry);
        if (_new) {
            _entry = {camera:_camera, current_x:_x, current_y:_y, previous_x:_x, previous_y:_y,
                width:_w, height:_h, angle:_angle, tick:-1, interpolated:false,
                saved_x:_x, saved_y:_y, saved_view_matrix:undefined};
            array_push(_t.cameras, _entry);
        }
        if (_entry.tick == timing_tick_id()) continue;
        var _changed = _entry.width != _w || _entry.height != _h || _entry.angle != _angle
            || _entry.current_x != _x || _entry.current_y != _y;
        _entry.previous_x = _x; _entry.previous_y = _y;
        // The native target reference retains its object/instance resolution.
        // Do not cast it or choose an instance by guessed numeric asset type.
        if (!_no_target && instance_exists(_target)) {
            _x = timing_camera_axis(_x, _w, camera_get_view_border_x(_camera),
                camera_get_view_speed_x(_camera), _target.x, room_width);
            _y = timing_camera_axis(_y, _h, camera_get_view_border_y(_camera),
                camera_get_view_speed_y(_camera), _target.y, room_height);
            camera_set_view_pos(_camera, _x, _y);
        }
        camera_set_update_script(_camera, timing_camera_native_disabled);
        _entry.current_x = _x; _entry.current_y = _y;
        _entry.width = _w; _entry.height = _h; _entry.angle = _angle;
        _entry.tick = timing_tick_id();
        if (_new || _changed) {
            _entry.previous_x = _x; _entry.previous_y = _y;
        }
    }
}

function timing_camera_before_draw(_alpha) {
    if (!timing_camera_enabled() || global.renderfps <= TCC_SIM_HZ) return;
    var _entries = global.tcc_timing.cameras;
    for (var _i = 0; _i < array_length(_entries); ++_i) {
        var _c = _entries[_i];
        if (!timing_camera_current(_c.camera)
            || camera_get_update_script(_c.camera) != timing_camera_native_disabled) continue;
        if (camera_get_view_width(_c.camera) != _c.width
            || camera_get_view_height(_c.camera) != _c.height
            || camera_get_view_angle(_c.camera) != _c.angle) continue;
        var _x = camera_get_view_x(_c.camera), _y = camera_get_view_y(_c.camera);
        if (_x != _c.current_x || _y != _c.current_y
            || point_distance(_c.previous_x, _c.previous_y, _x, _y) > 64) continue;
        _c.saved_x = _x; _c.saved_y = _y;
        _c.saved_view_matrix = timing_camera_matrix_copy(camera_get_view_mat(_c.camera));
        _c.interpolated = true;
        camera_set_view_pos(_c.camera, lerp(_c.previous_x, _c.current_x, _alpha),
            lerp(_c.previous_y, _c.current_y, _alpha));
    }
}
