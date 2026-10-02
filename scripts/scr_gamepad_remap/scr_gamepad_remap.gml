// Six actions, shared by settings and gameplay. Saved values are platform gp_ codes.
function gamepad_remap_buttons() {
    return [gp_face1, gp_face2, gp_face3, gp_face4, gp_shoulderl, gp_shoulderlb,
        gp_shoulderr, gp_shoulderrb, gp_select, gp_start, gp_stickl, gp_stickr,
        gp_padu, gp_padd, gp_padl, gp_padr];
}
function gamepad_remap_valid_button(_button) {
    return is_real(_button) && tcc_gamepad_button_index(_button) >= 0;
}
// Six actions cannot consume all seven choices. Keep the familiar Pause button
// whenever it is free, without reserving any button from the gameplay bindings.
function gamepad_remap_pause_for_bindings(_bindings) {
    var _choices = [gp_start, gp_select, gp_stickr, gp_stickl, gp_shoulderlb, gp_shoulderrb, gp_face2];
    for (var _i = 0; _i < array_length(_choices); ++_i) {
        var _used = false;
        for (var _j = 0; _j < min(6, array_length(_bindings)); ++_j) {
            if (_bindings[_j] == _choices[_i]) { _used = true; break; }
        }
        if (!_used) return _choices[_i];
    }
    return gp_start; // Unreachable for the six supported actions.
}
function gamepad_remap_pause_button() {
    var _bindings = array_create(6);
    for (var _i = 0; _i < 6; ++_i) _bindings[_i] = gamepad_remap_get(_i);
    return gamepad_remap_pause_for_bindings(_bindings);
}
function gamepad_button_display_name(_button) {
    var _names = ["A", "B", "X", "Y", "LB", "RB", "LT", "RT", "Back", "Start", "L3", "R3", "D-Up", "D-Down", "D-Left", "D-Right"];
    var _index = tcc_gamepad_button_index(_button);
    return _index >= 0 ? _names[_index] : "Unassigned";
}
function gamepad_remap_names() {
    return ["gp_bind_moveright", "gp_bind_moveleft", "gp_bind_jump", "gp_bind_interact", "gp_bind_skip", "gp_bind_restart"];
}
function gamepad_remap_default_buttons() {
    return [gp_padr, gp_padl, gp_face1, gp_shoulderrb, gp_face4, gp_shoulderlb];
}
function gamepad_remap_init() {
    gamepad_remap_defaults();
    global.gp_active_device = -1;
    global.gp_remap_releasing = false;
    global.gp_remap_release_device = -1;
    global.gp_remap_cancelled_at = -1;
}
function gamepad_remap_capture_active() {
    return variable_global_exists("gp_remap_listening") && global.gp_remap_listening >= 0;
}
function gamepad_remap_back_input(_escape_pressed, _back_pressed, _capturing) {
    return _escape_pressed || (_back_pressed && !_capturing);
}
function gamepad_remap_cancel() {
    if (gamepad_remap_capture_active()) {
        global.gp_remap_cancelled_at = current_time;
        global.gp_remap_releasing = true;
        global.gp_remap_release_device = variable_global_exists("gp_remap_device") ? global.gp_remap_device : -1;
    }
    global.gp_remap_listening = -1;
    global.editcontrols = -1;
    global.gp_remap_device = -1;
    keyboard_string = "";
}
function gamepad_remap_defaults() {
    var _buttons = gamepad_remap_default_buttons();
    for (var _i = 0; _i < 6; ++_i) gamepad_remap_set(_i, _buttons[_i]);
    gamepad_remap_cancel();
}
function gamepad_remap_get(_index) {
    if (_index < 0 || _index >= 6 || floor(_index) != _index) return gp_face1;
    var _names = gamepad_remap_names(), _defaults = gamepad_remap_default_buttons();
    var _button = variable_global_exists(_names[_index]) ? variable_global_get(_names[_index]) : _defaults[_index];
    return gamepad_remap_valid_button(_button) ? _button : _defaults[_index];
}
function gamepad_remap_set(_index, _button) {
    if (_index < 0 || _index >= 6 || floor(_index) != _index || !gamepad_remap_valid_button(_button)) return false;
    var _names = gamepad_remap_names();
    variable_global_set(_names[_index], _button);
    return true;
}
function gamepad_remap_analog_activity(_axes, _left_trigger = false, _right_trigger = false) {
    if (_left_trigger || _right_trigger) return true;
    for (var _i = 0; _i < array_length(_axes); ++_i) if (abs(_axes[_i]) > 0.2) return true;
    return false;
}
// Button presses take priority; otherwise deliberate analog input selects a pad.
// Preserve the current pad when it remains active, so two held sticks do not flicker.
function gamepad_remap_choose_device(_active, _connected, _pressed, _analog) {
    var _count = array_length(_connected);
    if (_active < 0 || _active >= _count || !_connected[_active]) _active = -1;
    for (var _i = 0; _i < _count; ++_i) if (_connected[_i] && _pressed[_i]) return _i;
    if (_active >= 0 && _analog[_active]) return _active;
    for (var _a = 0; _a < _count; ++_a) if (_connected[_a] && _analog[_a]) return _a;
    if (_active >= 0) return _active;
    for (var _c = 0; _c < _count; ++_c) if (_connected[_c]) return _c;
    return -1;
}
// Update once per input frame to follow the controller actually being used.
// Readers keep the cached selection, including no device, and notice unplugging.
// Explicit poll owners select newly connected pads through the same wrappers.
function gamepad_remap_active_device(_poll_activity = false) {
    if (!variable_global_exists("gp_active_device")) global.gp_active_device = -1;
    var _active = global.gp_active_device;
    if (_active >= 0 && !tcc_gamepad_is_connected(_active)) _active = -1;
    if (!_poll_activity) {
        global.gp_active_device = _active;
        return _active;
    }
    var _count = min(16, max(4, gamepad_get_device_count()));
    var _buttons = gamepad_remap_buttons();
    var _connected = array_create(_count, false), _pressed = array_create(_count, false), _analog = array_create(_count, false);
    for (var _device = 0; _device < _count; ++_device) {
        if (!tcc_gamepad_is_connected(_device)) continue;
        _connected[_device] = true;
        for (var _i = 0; _i < array_length(_buttons); ++_i) {
            if (tcc_gamepad_button_check_pressed(_device, _buttons[_i])) {
                _pressed[_device] = true;
                break;
            }
        }
        _analog[_device] = gamepad_remap_analog_activity([
            tcc_gamepad_axis_value(_device, gp_axislh), tcc_gamepad_axis_value(_device, gp_axislv),
            tcc_gamepad_axis_value(_device, gp_axisrh), tcc_gamepad_axis_value(_device, gp_axisrv)],
            tcc_gamepad_button_check(_device, gp_shoulderlb), tcc_gamepad_button_check(_device, gp_shoulderrb));
    }
    global.gp_active_device = gamepad_remap_choose_device(_active, _connected, _pressed, _analog);
    return global.gp_active_device;
}
// UI readers reuse the selected controller. The fullscreen input owner polls
// activity once per tick; Draw/prompt readers do not request another poll.
// Return before any platform read when no controller is available.
function gamepad_ui_down(_button) {
    var _device = gamepad_remap_active_device();
    if (_device < 0) return false;
    return tcc_gamepad_button_check(_device, _button);
}
function gamepad_ui_pressed(_button) {
    var _device = gamepad_remap_active_device();
    if (_device < 0) return false;
    return tcc_gamepad_button_check_pressed(_device, _button);
}
function gamepad_ui_released(_button) {
    var _device = gamepad_remap_active_device();
    if (_device < 0) return false;
    return tcc_gamepad_button_check_released(_device, _button);
}
function gamepad_ui_axis(_axis) {
    var _device = gamepad_remap_active_device();
    if (_device < 0) return 0;
    return tcc_gamepad_axis_value(_device, _axis);
}
function gamepad_ui_connected() {
    return gamepad_remap_active_device() >= 0;
}
function gamepad_remap_listen(_device = -1) {
    if (_device < 0) _device = gamepad_remap_active_device();
    if (_device < 0 || !tcc_gamepad_is_connected(_device)) return -1;
    var _buttons = gamepad_remap_buttons();
    for (var _i = 0; _i < array_length(_buttons); ++_i) {
        if (tcc_gamepad_button_check_pressed(_device, _buttons[_i])) return _buttons[_i];
    }
    return -1;
}
function gamepad_remap_any_held(_device) {
    if (_device < 0 || !tcc_gamepad_is_connected(_device)) return false;
    var _buttons = gamepad_remap_buttons();
    for (var _i = 0; _i < array_length(_buttons); ++_i) {
        if (tcc_gamepad_button_check(_device, _buttons[_i])) return true;
    }
    return false;
}
// Call between ini_open/ini_close.
function gamepad_remap_save() {
    var _keys = ["MoveRight", "MoveLeft", "Jump", "Interact", "Skip", "Restart"];
    for (var _i = 0; _i < 6; ++_i) ini_write_real("ControllerBindings", _keys[_i], gamepad_remap_get(_i));
}
function gamepad_remap_load() {
    var _keys = ["MoveRight", "MoveLeft", "Jump", "Interact", "Skip", "Restart"];
    var _defaults = gamepad_remap_default_buttons();
    for (var _i = 0; _i < 6; ++_i) {
        var _button = ini_read_real("ControllerBindings", _keys[_i], _defaults[_i]);
        gamepad_remap_set(_i, gamepad_remap_valid_button(_button) ? _button : _defaults[_i]);
    }
}
// The release event belongs to capture too, including a later Escape release.
function gamepad_remap_guard_state(_releasing, _cancelled_at, _frame, _held) {
    if (_cancelled_at == _frame) return {blocked:true, releasing:_releasing, cancelled_at:_cancelled_at};
    if (!_releasing) return {blocked:false, releasing:false, cancelled_at:_cancelled_at};
    return {blocked:true, releasing:_held, cancelled_at:_held ? _cancelled_at : _frame};
}
function gamepad_remap_input_blocked() {
    var _releasing = variable_global_exists("gp_remap_releasing") && global.gp_remap_releasing;
    var _cancelled_at = variable_global_exists("gp_remap_cancelled_at") ? global.gp_remap_cancelled_at : -1;
    var _held = false;
    if (_releasing) {
        var _device = variable_global_exists("gp_remap_release_device") ? global.gp_remap_release_device : -1;
        _held = timing_keyboard_down(vk_anykey) || timing_mouse_down(mb_left) || timing_mouse_down(mb_right)
            || gamepad_remap_any_held(_device);
    }
    var _state = gamepad_remap_guard_state(_releasing, _cancelled_at, current_time, _held);
    global.gp_remap_releasing = _state.releasing;
    global.gp_remap_cancelled_at = _state.cancelled_at;
    return _state.blocked;
}
// Lets the shared Back handler consume Escape regardless of instance Step order.
function gamepad_remap_consume_back() {
    if (gamepad_remap_capture_active()) {
        gamepad_remap_cancel();
        return true;
    }
    return gamepad_remap_input_blocked();
}

function gamepad_remap_selfcheck() {
    var _names = gamepad_remap_names(), _old = array_create(6);
    for (var _i = 0; _i < 6; ++_i) _old[_i] = gamepad_remap_get(_i);
    var _defaults = gamepad_remap_default_buttons(), _buttons = gamepad_remap_buttons();
    scr_port_assert(gamepad_remap_pause_for_bindings(_defaults) == gp_start, "default controls keep Start for Pause");
    scr_port_assert(gamepad_remap_pause_for_bindings([gp_start, gp_select, gp_stickr, gp_stickl, gp_shoulderlb, gp_shoulderrb]) == gp_face2,
        "six occupied pause choices still leave a reachable unassigned button");
    for (var _action = 0; _action < 6; ++_action) {
        for (var _b = 0; _b < array_length(_buttons); ++_b) {
            for (var _reset = 0; _reset < 6; ++_reset) gamepad_remap_set(_reset, _defaults[_reset]);
            scr_port_assert(gamepad_remap_set(_action, _buttons[_b]) && gamepad_remap_get(_action) == _buttons[_b],
                "every standard controller button binds to action " + string(_action));
            var _pause = gamepad_remap_pause_button();
            for (var _other = 0; _other < 6; ++_other)
                scr_port_assert(_pause != gamepad_remap_get(_other), "Pause never overlaps a gameplay binding");
        }
    }
    for (var _restore = 0; _restore < 6; ++_restore) gamepad_remap_set(_restore, _old[_restore]);
    scr_port_assert(!gamepad_remap_analog_activity([0.1,-0.19,0,0]) && gamepad_remap_analog_activity([0,0.21,0,0])
        && gamepad_remap_analog_activity([0,0,0,0],true), "analog activity ignores drift and includes sticks/triggers");
    scr_port_assert(gamepad_remap_choose_device(0,[true,true],[false,false],[false,true]) == 1,
        "second controller's stick selects it without a button press");
    scr_port_assert(gamepad_remap_choose_device(1,[true,true],[true,false],[false,true]) == 0
        && gamepad_remap_choose_device(1,[true,true],[false,false],[true,true]) == 1,
        "pressed button wins while simultaneous held sticks keep the active controller stable");
    scr_port_assert(gamepad_remap_choose_device(0,[false,true],[false,false],[false,false]) == 1
        && gamepad_remap_choose_device(1,[false,false],[false,false],[false,false]) == -1,
        "unplugging falls back to another connected controller or none");
    var _old_device = variable_global_exists("gp_active_device") ? global.gp_active_device : -1;
    global.gp_active_device = -1;
    scr_port_assert(gamepad_remap_active_device(false) == -1 && !gamepad_ui_connected()
        && !gamepad_ui_down(gp_face1) && gamepad_ui_axis(gp_axislh) == 0,
        "UI readers keep an absent cached pad until an input owner polls");
    global.gp_active_device = _old_device;
    scr_port_assert(gamepad_remap_valid_button(gp_face2)
        && !gamepad_remap_back_input(false,true,true)
        && gamepad_remap_back_input(false,true,false)
        && gamepad_remap_back_input(true,true,true), "B belongs to capture while Escape still cancels and B otherwise navigates back");
    var _held = gamepad_remap_guard_state(true,10,11,true);
    var _release = gamepad_remap_guard_state(_held.releasing,_held.cancelled_at,12,false);
    var _same_frame = gamepad_remap_guard_state(_release.releasing,_release.cancelled_at,12,false);
    var _next = gamepad_remap_guard_state(_release.releasing,_release.cancelled_at,13,false);
    scr_port_assert(_held.blocked && _held.releasing && _release.blocked && !_release.releasing
        && _same_frame.blocked && !_next.blocked, "capture cancellation consumes held input and its release before navigation resumes");
}
