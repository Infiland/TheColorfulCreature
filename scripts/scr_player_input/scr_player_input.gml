/// Merge the same six mapped actions on desktop, touch, and Steam Android.
function scr_player_input() {
    var _device = gamepad_remap_active_device(true);
    var _axis = _device < 0 ? 0 : tcc_gamepad_axis_value(_device, gp_axislh);
    key_left = timing_keyboard_down(settings_keyboard_code(global.controlsmoveleft)) || _axis < -0.2;
    key_right = timing_keyboard_down(settings_keyboard_code(global.controlsmoveright)) || _axis > 0.2;
    input_jump_held = timing_keyboard_down(settings_keyboard_code(global.controlsjump));
    var _jump_pressed = timing_keyboard_pressed(settings_keyboard_code(global.controlsjump));
    key_interact = timing_keyboard_pressed(settings_keyboard_code(global.controlsinteract));
    key_interact_h = timing_keyboard_down(settings_keyboard_code(global.controlsinteract));
    key_restart = timing_keyboard_down(settings_keyboard_code(global.controlsrestart));
    if (_device >= 0) {
        key_left |= tcc_gamepad_button_check(_device, gamepad_remap_get(1));
        key_right |= tcc_gamepad_button_check(_device, gamepad_remap_get(0));
        input_jump_held |= tcc_gamepad_button_check(_device, gamepad_remap_get(2));
        _jump_pressed |= tcc_gamepad_button_check_pressed(_device, gamepad_remap_get(2));
        key_interact |= tcc_gamepad_button_check_pressed(_device, gamepad_remap_get(3));
        key_interact_h |= tcc_gamepad_button_check(_device, gamepad_remap_get(3));
        key_restart |= tcc_gamepad_button_check(_device, gamepad_remap_get(5));
    }
    if (platform_touch()) {
        key_left |= instance_exists(o_buttonleftandroid) && (o_buttonleftandroid.pressed || o_buttonleftandroid.press);
        key_right |= instance_exists(o_buttonrightandroid) && (o_buttonrightandroid.pressed || o_buttonrightandroid.press);
        input_jump_held |= instance_exists(o_buttonjumpandroid) && o_buttonjumpandroid.pressed;
        _jump_pressed |= instance_exists(o_buttonjumpandroid) && o_buttonjumpandroid.press;
        key_interact |= instance_exists(o_buttoninteractandroid) && o_buttoninteractandroid.press;
        key_interact_h |= instance_exists(o_buttoninteractandroid) && (o_buttoninteractandroid.pressed || o_buttoninteractandroid.press);
        key_restart |= instance_exists(o_buttonrestartandroid) && o_buttonrestartandroid.press;
    }
    // A brief tap captured on a render-only frame still lasts one gameplay
    // tick. It must work for normal held jumps as well as airborne jump edges.
    input_jump_held |= _jump_pressed;
    key_jump = doublejump == 0 ? input_jump_held : _jump_pressed;
}

function player_skip_input(_pressed = false) {
    // Skips are intentionally outside the completion-witness input vocabulary.
    if (qa_active()) return false;
    var _key = settings_keyboard_code(global.controlsskiplevel);
    var _result = _pressed ? timing_keyboard_pressed(_key) : timing_keyboard_down(_key);
    var _device = gamepad_remap_active_device();
    if (_device >= 0) _result |= _pressed
        ? tcc_gamepad_button_check_pressed(_device, gamepad_remap_get(4))
        : tcc_gamepad_button_check(_device, gamepad_remap_get(4));
    if (platform_touch() && instance_exists(o_buttonskipandroid)) {
        _result |= _pressed ? o_buttonskipandroid.press : o_buttonskipandroid.pressed;
    }
    return _result;
}

function player_interact_pressed(_physical = false) {
    if (!_physical && qa_active() && global.tcc_qa.running && !global.tcc_qa.finished
        && global.tcc_qa.mode != "record") {
        var _q = global.tcc_qa;
        return !_q.preparing && timing_is_tick() && (_q.mask & 8) != 0 && (_q.previous & 8) == 0;
    }
    var _pressed = timing_keyboard_pressed(settings_keyboard_code(global.controlsinteract));
    var _device = gamepad_remap_active_device(true);
    if (_device >= 0) _pressed |= tcc_gamepad_button_check_pressed(_device, gamepad_remap_get(3));
    if (platform_touch() && instance_exists(o_buttoninteractandroid)) _pressed |= o_buttoninteractandroid.press;
    return _pressed;
}

// Touch navigation is one action per buffered tap. Held keyboard/controller
// navigation can repeat independently without an idle touch resetting it.
function player_menu_direction_held(_right, _include_touch = true) {
    if (qa_active() && global.tcc_qa.running && !global.tcc_qa.finished && global.tcc_qa.mode != "record") {
        var _q = global.tcc_qa;
        return !_q.preparing && timing_is_tick() && (_q.mask & (_right ? 2 : 1)) != 0;
    }
    var _held = timing_keyboard_down(_right ? vk_right : vk_left)
        || timing_keyboard_down(settings_keyboard_code(_right ? global.controlsmoveright : global.controlsmoveleft));
    var _device = gamepad_remap_active_device(true);
    if (_device >= 0) {
        var _axis = tcc_gamepad_axis_value(_device, gp_axislh);
        _held |= tcc_gamepad_button_check(_device, gamepad_remap_get(_right ? 0 : 1))
            || tcc_gamepad_button_check(_device, _right ? gp_padr : gp_padl)
            || (_right ? _axis > 0.2 : _axis < -0.2);
    }
    if (_include_touch && platform_touch()) {
        var _button = _right ? o_buttonrightandroid : o_buttonleftandroid;
        if (instance_exists(_button)) _held |= _button.press;
    }
    return _held;
}

function player_pause_pressed(_physical = false) {
    if (!_physical && qa_active() && global.tcc_qa.running && !global.tcc_qa.finished
        && global.tcc_qa.mode != "record") {
        var _q = global.tcc_qa;
        return !_q.preparing && timing_is_tick() && (_q.mask & 32) != 0 && (_q.previous & 32) == 0;
    }
    // Player Step exits while paused; selecting the pad belongs here too.
    var _device = gamepad_remap_active_device(true);
    return timing_keyboard_pressed(vk_escape)
        || (_device >= 0 && tcc_gamepad_button_check_pressed(_device, gamepad_remap_pause_button()));
}

// A ramp's sub-pixel settling is contact with the floor, not a falling pose.
// This value is for skin/eye animation only; it never changes velocity, the
// jump state, collision, or either player's established movement equations.
function player_animation_velocity() {
    if (zerogrv == 0 && vsp >= 0 && scr_slope_place(x, y + 1) != noone) return 0;
    return vsp;
}

// Single-player upward one-way platforms use a swept top-plane check. A
// sub-pixel fall must be stopped before it crosses the surface; waiting for a
// rounded mask overlap can put bbox_bottom below the old approach-side guard.
// Rising through a shelf and approaching its underside remain unobstructed.
function player_oneway_landing() {
    if (vsp <= 0 || !instance_exists(o_onewayupblock)) return;
    static _hits = ds_list_create();
    ds_list_clear(_hits);
    var _epsilon = max(0.0001, abs(y) * 0.00000012);
    collision_rectangle_list(bbox_left, bbox_bottom - _epsilon, bbox_right,
        bbox_bottom + vsp + 1, o_onewayupblock, false, true, _hits, false);
    var _top = infinity;
    for (var _i = 0; _i < ds_list_size(_hits); ++_i) {
        var _platform = _hits[| _i];
        var _gap = _platform.bbox_top - bbox_bottom;
        if (_gap >= -_epsilon && _gap <= vsp && _platform.bbox_top < _top)
            _top = _platform.bbox_top;
    }
    if (_top != infinity) {
        y = _top - (bbox_bottom - y);
        vsp = 0;
        onGround = true;
        onice = false;
        if (!onCelling) coyotetime = coyotetimeMAX;
    }
}
