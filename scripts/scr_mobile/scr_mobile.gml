function platform_clear_input() {
    timing_input_clear();
    keyboard_clear(vk_anykey);
    mouse_clear(mb_any);
    global.touch_blocked = true;
    instance_destroy(o_indicatorandroid);
    with (o_parentandroidbutton) {
        if (my_touch != -1) scr_saveandroid();
        my_touch = -1; touch_mask = 0; touch_previous = 0;
        press = 0; pressed = 0; image_index = 0;
    }
    with (o_player) {
        key_left = false; key_right = false; key_jump = false;
        key_interact = false; key_interact_h = false; key_restart = false;
    }
    for (var _i = 0; _i < 4; ++_i) gamepad_set_vibration(_i, 0, 0);
}

// Keep input/save/audio/ad lifecycles in each caller; share the menu and
// the existing keyboard/controller narrative and overlay restrictions.
function platform_pause_menu_allowed() {
    return instance_exists(o_pausesystem) && room != r_tale && room != r_theend
        && !instance_exists(o_settingspausemenu) && !instance_exists(o_hatshopmenu);
}

// The caller has already entered pause. Configure only newly created IDs so
// repeated calls cannot duplicate controls or alter unrelated instances.
function platform_pause_menu_create() {
    if (global.pause != 1 || !platform_pause_menu_allowed()) return false;
    if (!instance_exists(o_pausescreen)) instance_create(288, 288, o_pausescreen);
    if (!instance_exists(o_returnbutton)) {
        var _back = instance_create(480, 490, o_returnbutton);
        _back.ingame = true;
    }
    if (!instance_exists(o_settings)) {
        var _settings = instance_create(960, 704, o_settings);
        _settings.image_xscale = 2;
        _settings.image_yscale = 2;
    }
    if (!instance_exists(o_givefeedback)) {
        var _feedback = instance_create(750, 670, o_givefeedback);
        _feedback.image_xscale = 31;
        _feedback.image_yscale = 16;
        _feedback.xscale = 0.6;
        _feedback.yscale = 0.6;
    }
    // Normal challenge restarts reject Workshop, matching the pause-menu policy.
    if (global.challenges == 1 && global.workshop == 0
        && !instance_exists(o_restartchallengebutton)) {
        var _restart = instance_create(570, 670, o_restartchallengebutton);
        _restart.image_xscale = 32.8;
        _restart.image_yscale = 16.1;
        _restart.xscale = 0.5;
        _restart.yscale = 0.5;
    }
    timing_activate_object(o_pausescreen);
    return true;
}

function platform_interrupt() {
    timing_interrupt_clock();
    if (!variable_global_exists("tcc_loaded")) return;
    platform_clear_input();
    scr_savestats();
    scr_savegame();
    platform_services_save();
    if (global.pause != 0 || !platform_pause_menu_allowed()) return;
    global.pause = 1;
    timing_sequence_flush();
    audio_group_set_gain(Music, global.musicvolume / 5, 100);
    if (window_get_cursor() == cr_none) window_set_cursor(cr_arrow);
    platform_pause_menu_create();
}

function platform_mobile_step() {
    if (!platform_mobile()) return;
    var _background = os_is_paused();
    if (_background && !global.mobile_background) platform_interrupt();
    if (!_background && global.mobile_background && platform_google_play())
        platform_google_auth_begin();
    global.mobile_background = _background;
    if (global.touch_blocked) {
        var _held = false;
        for (var _i = 0; _i < 6; ++_i)
            _held = _held || device_mouse_check_button(_i, mb_left) || device_mouse_check_button_pressed(_i, mb_left);
        if (!_held) global.touch_blocked = false;
    }
}

// Keep the playfield's GUI origin/scale, but draw over the full window, including bars.
function platform_mobile_gui() {
    if (!platform_mobile()) return;
    var _pos = application_get_position();
    display_set_gui_size(-1, -1);
    display_set_gui_maximise((_pos[2] - _pos[0]) / 1024, (_pos[3] - _pos[1]) / 768, _pos[0], _pos[1]);
}

function platform_safe_inset(_edge) {
    return TCC_STEAM_ANDROID ? tcc_android_safe_inset(_edge) : tcc_safe_inset(_edge);
}

function platform_touch_bounds() {
    if (!platform_mobile()) return [0, 0, 1024, 768];
    var _pos = application_get_position();
    var _sx = 1024 / max(1, _pos[2] - _pos[0]);
    var _sy = 768 / max(1, _pos[3] - _pos[1]);
    return [(platform_safe_inset(0) * window_get_width() - _pos[0]) * _sx,
            (platform_safe_inset(1) * window_get_height() - _pos[1]) * _sy,
            ((1 - platform_safe_inset(2)) * window_get_width() - _pos[0]) * _sx,
            ((1 - platform_safe_inset(3)) * window_get_height() - _pos[1]) * _sy];
}

// Positions stay in playfield GUI units; negative X and X > 1024 use the side bars.
function platform_touch_defaults() {
    global.androidbuttonsize = 0;
    var _bounds = platform_touch_bounds();
    global.androidleftx = _bounds[0] + 112; global.androidlefty = _bounds[3] - 120;
    global.androidrightx = _bounds[0] + 304; global.androidrighty = _bounds[3] - 120;
    global.androidjumpx = _bounds[2] - 112; global.androidjumpy = _bounds[3] - 128;
    global.androidinteractx = _bounds[2] - 288; global.androidinteracty = _bounds[3] - 216;
    global.androidrestartx = _bounds[0] + 96; global.androidrestarty = 320;
    global.androidskipx = _bounds[2] - 104; global.androidskipy = 320;
}

function platform_touch_clamp(_value, _minimum, _maximum, _fallback) {
    if (!is_real(_value) || is_nan(_value) || is_infinity(_value)) return _fallback;
    return clamp(_value, _minimum, max(_minimum, _maximum));
}

function platform_touch_position(_x, _y) {
    image_xscale = touch_base_scale * (1 + 0.25 * global.androidbuttonsize);
    image_yscale = image_xscale;
    var _bounds = platform_touch_bounds();
    var _origin_x = sprite_get_xoffset(sprite_index) * image_xscale;
    var _origin_y = sprite_get_yoffset(sprite_index) * image_yscale;
    gui_x = platform_touch_clamp(_x, _bounds[0] + _origin_x + 12, _bounds[2] - sprite_width + _origin_x - 12, 512);
    gui_y = platform_touch_clamp(_y, _bounds[1] + _origin_y + 12, _bounds[3] - sprite_height + _origin_y - 12, 384);
    x = camera_get_view_x(view_camera[0]) + gui_x;
    y = camera_get_view_y(view_camera[0]) + gui_y;
}

function platform_touch_claim(_finger, _tx, _ty) {
    if (my_touch != -1) return false;
    for (var _i = 0; _i < instance_number(o_parentandroidbutton); ++_i) {
        if (instance_find(o_parentandroidbutton, _i).my_touch == _finger) return false;
    }
    my_touch = _finger;
    drag_offset_x = gui_x - _tx;
    drag_offset_y = gui_y - _ty;
    return true;
}

function platform_touch_move(_tx, _ty) {
    platform_touch_position(_tx + drag_offset_x, _ty + drag_offset_y);
    variable_global_set("android" + touch_name + "x", gui_x);
    variable_global_set("android" + touch_name + "y", gui_y);
}

function platform_skip_progress(_remaining) {
    return clamp(1 - _remaining / 0.7, 0, 1);
}

// Position every control before hit testing; sample once, before any gameplay Step.
function platform_touch_begin() {
    var _editing = global.choosesettings == 3 && (room == r_settings || instance_exists(o_settingspausemenu));
    with (o_parentandroidbutton) {
        touch_previous = touch_mask;
        touch_mask = 0;
        press = false; pressed = false; image_index = 0; alpha = 0.7;
        if (my_touch != -1 && (!_editing || global.touch_blocked || global.mobile_background || !device_mouse_check_button(my_touch, mb_left))) {
            my_touch = -1;
            scr_saveandroid();
        }
        if (touch_name != "")
            platform_touch_position(variable_global_get("android" + touch_name + "x"), variable_global_get("android" + touch_name + "y"));
        else
            platform_touch_position(928, 8);
    }
    return _editing;
}

function platform_touch_sample(_finger, _tx, _ty, _started, _editing) {
    if (instance_exists(global.mobile_confirmation) || global.touch_blocked || global.mobile_background) return;
    var _bit = 1 << _finger;
    var _target = noone;
    var _nearest = 0;
    with (o_parentandroidbutton) {
        if (_editing) {
            if (touch_name == "") continue;
            if (my_touch == _finger) { _target = id; break; }
            if (my_touch != -1 || !_started) continue;
        } else if (global.pause != 0 && object_index != o_buttonpauseandroid) continue;
        // Tolerate thumb drift, but still slide to the nearest adjacent control.
        var _padding = _editing ? 0 : ((touch_previous & _bit) != 0 ? 32 : 16);
        var _left = gui_x - sprite_get_xoffset(sprite_index) * image_xscale;
        var _top = gui_y - sprite_get_yoffset(sprite_index) * image_yscale;
        if (!point_in_rectangle(_tx, _ty, _left - _padding, _top - _padding, _left + sprite_width + _padding, _top + sprite_height + _padding)) continue;
        var _dx = _tx - (_left + sprite_width / 2);
        var _dy = _ty - (_top + sprite_height / 2);
        var _distance = _dx * _dx + _dy * _dy;
        if (_target == noone || _distance < _nearest) { _target = id; _nearest = _distance; }
    }
    if (_target == noone) return;
    with (_target) {
        if (_editing) {
            if (my_touch == -1 && !platform_touch_claim(_finger, _tx, _ty)) return;
            platform_touch_move(_tx, _ty);
        }
        // Preserve native re-taps and second-finger taps on an already-held button.
        press = press || _started || (touch_previous & _bit) == 0;
        touch_mask |= _bit;
        pressed = true; image_index = 1; alpha = 1;
    }
}

function platform_touch_step() {
    var _editing = platform_touch_begin();
    for (var _i = 0; _i < 6; ++_i) {
        var _started = device_mouse_check_button_pressed(_i, mb_left);
        if (!device_mouse_check_button(_i, mb_left) && !_started) continue;
        platform_touch_sample(_i, device_mouse_x_to_gui(_i), device_mouse_y_to_gui(_i), _started, _editing);
    }
}
