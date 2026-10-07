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
    // Background and controller pauses need the same uncluttered overlay as a
    // touch pause. Only the resume control remains interactive while paused.
    if (platform_mobile()) {
        with (o_parentandroidbutton) {
            if (object_index != o_buttonpauseandroid) instance_destroy();
        }
    }
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
    var _rect = platform_touch_gui_rect();
    display_set_gui_size(-1, -1);
    display_set_gui_maximise(_rect[2], _rect[3], _rect[0], _rect[1]);
}

function platform_safe_inset(_edge) {
    return TCC_STEAM_ANDROID ? tcc_android_safe_inset(_edge) : tcc_safe_inset(_edge);
}

// Touch controls never cover gameplay. While they are shown, the 4:3 playfield
// shrinks only as far as the device needs (iPads the most) for every default
// control to sit in the side bars or below it. GUI units stay playfield units.
#macro TCC_TOUCH_MARGIN 16
#macro TCC_TOUCH_HUD_WIDTH 96

function platform_touch_scale() {
    return 1 + 0.25 * (variable_global_exists("androidbuttonsize") ? global.androidbuttonsize : 0);
}

// Default centres in GUI units for safe bounds _b; pause keeps its top-left origin.
function platform_touch_default_layout(_b, _k) {
    var _m = TCC_TOUCH_MARGIN, _move = 64 * _k, _jump = 70.4 * _k, _small = 48 * _k;
    var _bottom = _b[3] - _m;
    return {
        leftx: _b[0] + _m + _move, lefty: _bottom - _move,
        rightx: _b[0] + _m + _move + 192 * _k, righty: _bottom - _move,
        jumpx: _b[2] - _m - _jump, jumpy: _bottom - _jump,
        interactx: _b[2] - _m - _jump - 200 * _k, interacty: _bottom - _move,
        restartx: _b[0] + _m + _small, restarty: 384,
        skipx: _b[2] - _m - _small, skipy: 384,
        pausex: _b[2] - _m - 2 * _small, pausey: _b[1] + _m
    };
}

// Controls plus the coin total drawn above the skip control.
function platform_touch_layout_clear(_l, _k) {
    var _move = 64 * _k, _jump = 70.4 * _k, _small = 48 * _k;
    var _rects = [
        [_l.leftx - _move, _l.lefty - _move, _l.leftx + _move, _l.lefty + _move],
        [_l.rightx - _move, _l.righty - _move, _l.rightx + _move, _l.righty + _move],
        [_l.interactx - _move, _l.interacty - _move, _l.interactx + _move, _l.interacty + _move],
        [_l.jumpx - _jump, _l.jumpy - _jump, _l.jumpx + _jump, _l.jumpy + _jump],
        [_l.restartx - _small, _l.restarty - _small, _l.restartx + _small, _l.restarty + _small],
        [_l.skipx - _small, _l.skipy - _small, _l.skipx + _small, _l.skipy + _small],
        [_l.pausex, _l.pausey, _l.pausex + 2 * _small, _l.pausey + 2 * _small],
        [_l.skipx - TCC_TOUCH_HUD_WIDTH / 2, _l.skipy - _small - 92,
         _l.skipx + TCC_TOUCH_HUD_WIDTH / 2, _l.skipy - _small - 54]
    ];
    for (var _i = 0; _i < array_length(_rects); ++_i) {
        var _r = _rects[_i];
        if (_r[2] > 0.5 && _r[0] < 1023.5 && _r[3] > 0.5 && _r[1] < 767.5) return false;
    }
    return true;
}

// [window x, window y, pixels per GUI unit] of a playfield at fraction _f of the fitted size.
function platform_touch_playfield(_f, _top) {
    var _w = max(1, window_get_width()), _h = max(1, window_get_height());
    var _unit = _f * min(_w / 1024, _h / 768);
    var _y = _top ? min(platform_safe_inset(1) * _h, _h - 768 * _unit) : (_h - 768 * _unit) / 2;
    return [(_w - 1024 * _unit) / 2, _y, _unit];
}

function platform_touch_safe_bounds(_rect) {
    var _w = max(1, window_get_width()), _h = max(1, window_get_height());
    return [(platform_safe_inset(0) * _w - _rect[0]) / _rect[2], (platform_safe_inset(1) * _h - _rect[1]) / _rect[2],
            ((1 - platform_safe_inset(2)) * _w - _rect[0]) / _rect[2], ((1 - platform_safe_inset(3)) * _h - _rect[1]) / _rect[2]];
}

// Largest playfield (centred, else top-aligned) that leaves the default controls clear.
function platform_touch_layout() {
    var _w = max(1, window_get_width()), _h = max(1, window_get_height()), _k = platform_touch_scale();
    var _key = string(_w) + "," + string(_h) + "," + string(_k);
    for (var _edge = 0; _edge < 4; ++_edge) _key += "," + string(platform_safe_inset(_edge));
    var _previous = variable_global_exists("touch_layout") ? global.touch_layout : undefined;
    if (!is_undefined(_previous) && _previous.key == _key) return _previous;
    var _rect = undefined, _fraction = 0.6;
    for (var _step = 0; _step <= 40 && is_undefined(_rect); ++_step) {
        for (var _top = 0; _top <= 1; ++_top) {
            var _candidate = platform_touch_playfield(1 - _step / 100, _top);
            if (platform_touch_layout_clear(platform_touch_default_layout(platform_touch_safe_bounds(_candidate), _k), _k)) {
                _rect = _candidate; _fraction = 1 - _step / 100;
                break;
            }
        }
    }
    _rect ??= platform_touch_playfield(_fraction, true);
    _rect = [round(_rect[0]), round(_rect[1]), _rect[2]];
    var _layout = {key: _key, fraction: _fraction, shrink: _fraction < 1};
    _layout.rect = _rect;
    _layout.bounds = platform_touch_safe_bounds(_rect);
    _layout.defaults = platform_touch_default_layout(_layout.bounds, _k);
    global.touch_layout = _layout;
    // Controls still at the previous defaults follow a new size or safe area.
    if (!is_undefined(_previous) && platform_touch_at_defaults(_previous.defaults)) platform_touch_place_defaults();
    return _layout;
}

function platform_touch_at_defaults(_defaults) {
    if (!variable_global_exists("androidleftx")) return false;
    var _names = ["left", "right", "jump", "interact", "restart", "skip"];
    for (var _i = 0; _i < array_length(_names); ++_i) {
        if (abs(variable_global_get("android" + _names[_i] + "x") - variable_struct_get(_defaults, _names[_i] + "x")) > 0.5
            || abs(variable_global_get("android" + _names[_i] + "y") - variable_struct_get(_defaults, _names[_i] + "y")) > 0.5) return false;
    }
    return true;
}

// Room-space taps go unused during touch play, so while the controls are shown
// the application surface is drawn into the solved playfield. Pause, settings
// and other menus keep GameMaker's own composite, whose room taps they rely on.
function platform_touch_composite_wanted() {
    if (!platform_mobile() || room == r_settings || !instance_exists(o_buttonleftandroid)) return false;
    if (!variable_global_exists("pause") || global.pause != 0) return false;
    return platform_touch_layout().shrink;
}

// The colour-blindness simulator owns manual drawing of the application surface.
function platform_touch_composited() {
    return platform_touch_composite_wanted() && instance_exists(o_ColorBlindnessSimulation)
        && o_ColorBlindnessSimulation.manual_draw_active;
}

// Where the application surface belongs this frame: [x, y, width, height] in window pixels.
function platform_app_surface_rect() {
    if (platform_touch_composited()) {
        var _r = platform_touch_layout().rect;
        return [_r[0], _r[1], 1024 * _r[2], 768 * _r[2]];
    }
    var _pos = application_get_position();
    return [_pos[0], _pos[1], _pos[2] - _pos[0], _pos[3] - _pos[1]];
}

// Current GUI mapping: [x, y, x scale, y scale] of playfield GUI units in window pixels.
function platform_touch_gui_rect() {
    var _r = platform_app_surface_rect();
    return [_r[0], _r[1], _r[2] / 1024, _r[3] / 768];
}

// Controls are stored in solved-layout units, which equal GUI units during touch
// play; elsewhere they convert so each control keeps its place on screen.
function platform_touch_to_gui(_x, _y) {
    var _l = platform_touch_layout().rect, _g = platform_touch_gui_rect();
    return [(_l[0] + _x * _l[2] - _g[0]) / _g[2], (_l[1] + _y * _l[2] - _g[1]) / _g[3], _l[2] / _g[2]];
}

function platform_touch_from_gui(_x, _y) {
    var _l = platform_touch_layout().rect, _g = platform_touch_gui_rect();
    return [(_g[0] + _x * _g[2] - _l[0]) / _l[2], (_g[1] + _y * _g[3] - _l[1]) / _l[2]];
}

function platform_touch_bounds() {
    if (!platform_mobile()) return [0, 0, 1024, 768];
    return platform_touch_layout().bounds;
}

// Positions are solved-layout units; negative X and X > 1024 use the side bars.
function platform_touch_defaults() {
    global.androidbuttonsize = 0;
    platform_touch_place_defaults();
}

function platform_touch_place_defaults() {
    var _l = platform_mobile() ? platform_touch_layout().defaults
        : platform_touch_default_layout([0, 0, 1024, 768], platform_touch_scale());
    global.androidleftx = _l.leftx; global.androidlefty = _l.lefty;
    global.androidrightx = _l.rightx; global.androidrighty = _l.righty;
    global.androidjumpx = _l.jumpx; global.androidjumpy = _l.jumpy;
    global.androidinteractx = _l.interactx; global.androidinteracty = _l.interacty;
    global.androidrestartx = _l.restartx; global.androidrestarty = _l.restarty;
    global.androidskipx = _l.skipx; global.androidskipy = _l.skipy;
}

// Coin total centred above the skip control. Keep the exact balance inside the
// reserved HUD width, including its shake, without resizing the playfield when
// a balance gains a digit. Return the draw scale as well as the converted origin.
function platform_touch_coin_hud(_button, _text_width) {
    var _bounds = platform_touch_bounds(), _width = 48 + _text_width;
    var _fit = min(1, (TCC_TOUCH_HUD_WIDTH - 4) / max(1, _width));
    _width *= _fit;
    var _gui = platform_touch_to_gui(clamp(_button.gui_x - _width / 2, _bounds[0] + 12, max(_bounds[0] + 12, _bounds[2] - 12 - _width)),
                                    max(_bounds[1] + 12, _button.gui_y - _button.sprite_height / 2 - 92));
    _gui[2] *= _fit;
    return _gui;
}

// Shared Draw GUI End. Tutorial levels pulse the real controls instead of
// showing look-alike arrow signs inside the level.
function platform_touch_draw() {
    var _gui = platform_touch_to_gui(gui_x, gui_y), _scale = _gui[2];
    draw_sprite_ext(sprite_index, image_index, _gui[0], _gui[1], image_xscale * _scale, image_yscale * _scale, 0, c_white, alpha);
    // Pausing recreates the controls, so remember use per control, not per instance.
    if (!variable_global_exists("touch_hint_rooms")) global.touch_hint_rooms = {};
    if (pressed) global.touch_hint_rooms[$ touch_name] = room;
    if (global.pause != 0 || global.touch_hint_rooms[$ touch_name] == room) return;
    var _tutorial = noone;
    if (object_index == o_buttonleftandroid || object_index == o_buttonrightandroid) _tutorial = o_Tutorial1;
    else if (object_index == o_buttonjumpandroid) _tutorial = o_Tutorial2;
    if (_tutorial == noone || !instance_exists(_tutorial)) return;
    var _t = (current_time mod 1000) / 1000;
    var _radius = (sprite_width / 2 + 4 + 14 * _t) * _scale;
    draw_set_color(make_color_rgb(230, 20, 20));
    draw_set_alpha(1 - _t);
    for (var _i = 0; _i < 4; ++_i) draw_circle(_gui[0], _gui[1], _radius + _i, true);
    draw_set_alpha(1);
    draw_set_color(c_white);
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
    var _editing = global.choosesettings == 7 && (room == r_settings || instance_exists(o_settingspausemenu));
    var _defaults = platform_touch_layout().defaults;
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
            platform_touch_position(_defaults.pausex, _defaults.pausey);
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
        var _point = platform_touch_from_gui(device_mouse_x_to_gui(_i), device_mouse_y_to_gui(_i));
        platform_touch_sample(_i, _point[0], _point[1], _started, _editing);
    }
}
