/// Native simulation keeps the established 60 FPS rules. Render-only engine
/// frames hold movement, alarms and animation; the engine still owns movement,
/// collision dispatch and event order on each simulation tick.
#macro TCC_SIM_HZ 60
#macro TCC_INPUT_CLOCK "simulation-60"

function timing_boot() {
    if (variable_global_exists("tcc_timing")) return;
    global.maxfps = TCC_SIM_HZ;
    if (!variable_global_exists("renderfps")) global.renderfps = TCC_SIM_HZ;
    global.delta = 1;
    global.tcc_timing = {
        begin_pending:true, first:true, tick:true, tick_id:0, render_id:0,
        clock_us:get_timer(), elapsed_us:0, accumulator_us:0,
        draw_accumulator_us:1000000 / TCC_SIM_HZ, draw_frame:true,
        drawn_frames:0, last_draw_us:0, draw_seconds:1 / TCC_SIM_HZ,
        native_rate:TCC_SIM_HZ, room_id:noone, room_generation:0,
        activation_dirty:false, alarm_phase_passed:false, tracked:[], tracked_set:ds_map_create(),
        pending:[], restored_render:0, ended_render:0,
        moving_layers:[], layer_room_id:noone, cameras:[],
        pause_clock:false, resume_boundary:false, interrupt_pending:false,
        clock_pause_applied:false, clock_resume_applied:false, clock_background_applied:false,
        clock_accumulator_before_us:0, interrupt_serial:0, consumed_interrupt_serial:0, interrupt_consumption:undefined,
        keyboard_pressed:array_create(256, false),
        keyboard_released:array_create(256, false),
        mouse_pressed:array_create(3, false), mouse_released:array_create(3, false),
        keyboard_any_pressed:false, keyboard_any_released:false,
        wheel_up:false, wheel_down:false,
        pads_pressed:[], pads_released:[],
        pads_connected:array_create(16, false), pads_generation:array_create(16, 0),
        visual_seed:246813579
    };
    global.timing_confirmation_dispatch_active = false;
    var _t = global.tcc_timing;
    for (var _p = 0; _p < 16; ++_p) {
        _t.pads_pressed[_p] = array_create(16, false);
        _t.pads_released[_p] = array_create(16, false);
    }
    var _sprites = asset_get_ids(asset_sprite);
    for (var _s = 0; _s < array_length(_sprites); ++_s) timing_normalize_sprite(_sprites[_s]);
    _t.clock_us = get_timer();
}

function timing_is_tick() { return !variable_global_exists("tcc_timing") || global.tcc_timing.tick; }
function timing_tick_id() { return variable_global_exists("tcc_timing") ? global.tcc_timing.tick_id : 0; }
function timing_tick_seconds() { return timing_is_tick() ? 1 / TCC_SIM_HZ : 0; }
// render_id identifies outer engine frames, including frames whose drawing is
// suppressed. It is deliberately separate from actual generated Draw frames.
function timing_render_id() { return variable_global_exists("tcc_timing") ? global.tcc_timing.render_id : 0; }
function timing_render_elapsed_seconds() { return variable_global_exists("tcc_timing") ? global.tcc_timing.elapsed_us / 1000000 : 0; }
function timing_render_seconds() { return min(0.1, timing_render_elapsed_seconds()); }
function timing_background_event() {
    return variable_global_exists("tcc_timing") ? global.tcc_timing.interrupt_pending : os_is_paused();
}
function timing_interrupt_clock() {
    // Service/OS callbacks can suspend between frames, without an End Step.
    // Retain that explicit boundary even if os_is_paused() is false on return.
    if (variable_global_exists("tcc_timing")) {
        global.tcc_timing.resume_boundary = true;
        global.tcc_timing.interrupt_serial += 1;
    }
}

function timing_apply_render_rate() {
    timing_boot();
    global.maxfps = TCC_SIM_HZ;
    global.renderfps = settings_fps_value(global.renderfps);
    var _rate = max(TCC_SIM_HZ, global.renderfps);
    global.tcc_timing.native_rate = _rate;
    game_set_speed(_rate, gamespeed_fps);
}

function timing_normalize_sprite(_sprite) {
    if (!sprite_exists(_sprite)) return;
    if (sprite_get_speed_type(_sprite) == spritespeed_framespersecond)
        sprite_set_speed(_sprite, sprite_get_speed(_sprite) / TCC_SIM_HZ, spritespeed_framespergameframe);
}

// Visual jitter has its own state. Drawing more often never consumes a
// gameplay random number or reseeds the engine's gameplay stream.
function timing_visual_random(_upper) {
    timing_boot();
    var _t = global.tcc_timing;
    _t.visual_seed = (_t.visual_seed * 48271) mod 2147483647;
    return (_t.visual_seed / 2147483647) * _upper;
}
function timing_visual_random_range(_low, _high) { return _low + timing_visual_random(_high - _low); }
function timing_visual_irandom(_upper) { return floor(timing_visual_random(max(0, floor(_upper)) + 1)); }
function timing_visual_irandom_range(_low, _high) {
    return ceil(min(_low, _high)) + timing_visual_irandom(floor(max(_low, _high)) - ceil(min(_low, _high)));
}

function timing_input_clear() {
    if (!variable_global_exists("tcc_timing")) return;
    var _t = global.tcc_timing;
    for (var _key = 0; _key < 256; ++_key) {
        _t.keyboard_pressed[_key] = false;
        _t.keyboard_released[_key] = false;
    }
    for (var _button = 0; _button < 3; ++_button) {
        _t.mouse_pressed[_button] = false;
        _t.mouse_released[_button] = false;
    }
    _t.keyboard_any_pressed = false; _t.keyboard_any_released = false;
    _t.wheel_up = false; _t.wheel_down = false;
    _t.interrupt_pending = false;
    for (var _p = 0; _p < 16; ++_p) {
        for (var _b = 0; _b < 16; ++_b) {
            _t.pads_pressed[_p][_b] = false;
            _t.pads_released[_p][_b] = false;
        }
    }
    with (o_parentandroidbutton) {
        timing_touch_press = false;
    }
}

function timing_input_capture() {
    var _t = global.tcc_timing;
    // Input sampling remains on every outer frame, before gameplay. Polling
    // belongs here so Begin Step instance ordering cannot change touch edges.
    if (instance_exists(o_fullscreensystem)) {
        platform_mobile_gui();
        platform_mobile_step();
        if (TCC_APPSTORE_GAMEPAD && os_type == os_macosx) tcc_gc_poll();
        if (platform_mobile()) platform_touch_step();
        if (platform_touch() && instance_exists(global.mobile_confirmation)) {
            with (global.mobile_confirmation) mobile_confirmation_step();
        }
    }
    if (keyboard_check_pressed(vk_anykey) || keyboard_check_released(vk_anykey)) {
        _t.keyboard_any_pressed |= keyboard_check_pressed(vk_anykey);
        _t.keyboard_any_released |= keyboard_check_released(vk_anykey);
        for (var _key = 2; _key < 256; ++_key) {
            _t.keyboard_pressed[_key] |= keyboard_check_pressed(_key);
            _t.keyboard_released[_key] |= keyboard_check_released(_key);
        }
    }
    _t.wheel_up |= mouse_wheel_up(); _t.wheel_down |= mouse_wheel_down();
    var _buttons = [mb_left, mb_right, mb_middle];
    for (var _b = 0; _b < 3; ++_b) {
        _t.mouse_pressed[_b] |= mouse_check_button_pressed(_buttons[_b]);
        _t.mouse_released[_b] |= mouse_check_button_released(_buttons[_b]);
    }
    var _pads = min(16, max(4, gamepad_get_device_count()));
    var _pad_buttons = [gp_face1, gp_face2, gp_face3, gp_face4,
        gp_shoulderl, gp_shoulderr, gp_shoulderlb, gp_shoulderrb, gp_select,
        gp_start, gp_stickl, gp_stickr, gp_padu, gp_padd, gp_padl, gp_padr];
    for (var _pad = 0; _pad < 16; ++_pad) {
        var _connected = _pad < _pads && tcc_gamepad_is_connected(_pad);
        if (!_connected) {
            if (_t.pads_connected[_pad]) _t.pads_generation[_pad] += 1;
            _t.pads_connected[_pad] = false;
            for (var _clear = 0; _clear < 16; ++_clear) {
                _t.pads_pressed[_pad][_clear] = false;
                _t.pads_released[_pad][_clear] = false;
            }
            continue;
        }
        _t.pads_connected[_pad] = true;
        for (var _pb = 0; _pb < 16; ++_pb) {
            _t.pads_pressed[_pad][_pb] |= tcc_gamepad_button_pressed_raw(_pad, _pad_buttons[_pb]);
            _t.pads_released[_pad][_pb] |= tcc_gamepad_button_released_raw(_pad, _pad_buttons[_pb]);
        }
    }
    with (o_parentandroidbutton) {
        if (!variable_instance_exists(id, "timing_touch_press")) timing_touch_press = false;
        timing_touch_press |= press;
        // The normal player and mobile menu read the same once-per-tick edge.
        if (_t.tick) press |= timing_touch_press;
    }
    timing_gameplay_render_input();
}

function timing_keyboard_pressed(_key) {
    if (!variable_global_exists("tcc_timing") || !timing_is_tick()) return keyboard_check_pressed(_key);
    if (_key == vk_anykey) return global.tcc_timing.keyboard_any_pressed || keyboard_check_pressed(_key);
    return (_key >= 0 && _key < 256 && global.tcc_timing.keyboard_pressed[_key]) || keyboard_check_pressed(_key);
}
function timing_keyboard_released(_key) {
    if (!variable_global_exists("tcc_timing") || !timing_is_tick()) return keyboard_check_released(_key);
    if (_key == vk_anykey) return global.tcc_timing.keyboard_any_released || keyboard_check_released(_key);
    return (_key >= 0 && _key < 256 && global.tcc_timing.keyboard_released[_key]) || keyboard_check_released(_key);
}
function timing_keyboard_down(_key) {
    if (_key == vk_anykey && variable_global_exists("tcc_timing") && timing_is_tick())
        return keyboard_check(_key) || global.tcc_timing.keyboard_any_pressed;
    return keyboard_check(_key) || (variable_global_exists("tcc_timing") && timing_is_tick()
        && _key >= 0 && _key < 256 && global.tcc_timing.keyboard_pressed[_key]);
}
function timing_mouse_index(_button) {
    switch (_button) { case mb_left:return 0; case mb_right:return 1; case mb_middle:return 2; }
    return -1;
}
function timing_mouse_pressed(_button) {
    var _index = timing_mouse_index(_button);
    return mouse_check_button_pressed(_button) || (variable_global_exists("tcc_timing")
        && timing_is_tick() && _index >= 0 && global.tcc_timing.mouse_pressed[_index]);
}
function timing_mouse_released(_button) {
    var _index = timing_mouse_index(_button);
    return mouse_check_button_released(_button) || (variable_global_exists("tcc_timing")
        && timing_is_tick() && _index >= 0 && global.tcc_timing.mouse_released[_index]);
}
function timing_mouse_down(_button) {
    var _index = timing_mouse_index(_button);
    return mouse_check_button(_button) || (variable_global_exists("tcc_timing")
        && timing_is_tick() && _index >= 0 && global.tcc_timing.mouse_pressed[_index]);
}
function timing_mouse_wheel_up() {
    return mouse_wheel_up() || (variable_global_exists("tcc_timing") && timing_is_tick() && global.tcc_timing.wheel_up);
}
function timing_mouse_wheel_down() {
    return mouse_wheel_down() || (variable_global_exists("tcc_timing") && timing_is_tick() && global.tcc_timing.wheel_down);
}
function timing_device_mouse_pressed(_device, _button) {
    return _device == 0 ? timing_mouse_pressed(_button) : device_mouse_check_button_pressed(_device, _button);
}
function timing_device_mouse_released(_device, _button) {
    return _device == 0 ? timing_mouse_released(_button) : device_mouse_check_button_released(_device, _button);
}
function timing_device_mouse_down(_device, _button) {
    return _device == 0 ? timing_mouse_down(_button) : device_mouse_check_button(_device, _button);
}
// A listening session belongs to one observed controller connection.
function timing_pad_generation(_device) {
    if (!variable_global_exists("tcc_timing") || _device < 0 || _device >= 16) return 0;
    return global.tcc_timing.pads_generation[_device];
}
function timing_pad_pressed(_device, _button) {
    var _index = tcc_gamepad_button_index(_button);
    return tcc_gamepad_button_pressed_raw(_device, _button) || (variable_global_exists("tcc_timing")
        && timing_is_tick() && _device >= 0 && _device < 16 && _index >= 0
        && global.tcc_timing.pads_pressed[_device][_index]);
}
function timing_pad_released(_device, _button) {
    var _index = tcc_gamepad_button_index(_button);
    return tcc_gamepad_button_released_raw(_device, _button) || (variable_global_exists("tcc_timing")
        && timing_is_tick() && _device >= 0 && _device < 16 && _index >= 0
        && global.tcc_timing.pads_released[_device][_index]);
}

function timing_native_active() {
    // These helpers move by ordinary Step assignments, with no native speed.
    // Their pose history still belongs to the same presentation timeline.
    if (object_index == o_smoothcamera || object_index == o_smoothcameraboss5) return true;
    // Custom Draw can animate image_index without an assigned sprite. Opt in
    // explicitly so these phases are held too, without tracking every marker.
    if (variable_instance_exists(id, "timing_manual_animation") && timing_manual_animation) return true;
    if (speed != 0 || gravity != 0 || friction != 0 || path_index != -1) return true;
    if (sprite_exists(sprite_index) && sprite_get_number(sprite_index) > 1 && image_speed != 0) return true;
    if (variable_instance_exists(id, "hsp") || variable_instance_exists(id, "vsp")) return true;
    for (var _a = 0; _a < 12; ++_a) if (alarm[_a] > 0) return true;
    return false;
}

function timing_instance_register_now() {
    if (!variable_global_exists("tcc_timing") || object_index == o_deltatime) return;
    if (!variable_instance_exists(id, "timing_native")) {
        if (!timing_native_active()) return;
        timing_normalize_sprite(sprite_index);
        timing_native = {held:false, start_x:x, start_y:y, previous_x:x, previous_y:y,
            current_x:x, current_y:y, draw_x:x, draw_y:y, interpolated:false,
            speed:speed, direction:direction, gravity:gravity, friction:friction,
            hspeed:hspeed, vspeed:vspeed,
            path_speed:path_speed, image_speed:image_speed, alarm_render:-1,
            resume_tick_id:-1, resume_speed:0, resume_direction:0,
            resume_hspeed:0, resume_vspeed:0};
    }
    if (!ds_map_exists(global.tcc_timing.tracked_set, id)) {
        global.tcc_timing.tracked_set[? id] = true;
        array_push(global.tcc_timing.tracked, id);
    }
}

function timing_register_instance(_id) {
    if (!variable_global_exists("tcc_timing") || !instance_exists(_id)) return;
    // Leave Create/caller assignments intact until the pre-motion boundary.
    // Freezing before returning would make a later speed=0 indistinguishable
    // from the clock's hold and could resurrect movement on the next tick.
    array_push(global.tcc_timing.pending, _id);
}

// Layer scrolling is native per-engine-frame motion too. Cache only moving
// layers, retaining the engine's own offsets and exact velocity values.
function timing_register_layer(_layer) {
    if (!variable_global_exists("tcc_timing") || !layer_exists(_layer)) return;
    var _t = global.tcc_timing;
    for (var _i = 0; _i < array_length(_t.moving_layers); ++_i)
        if (_t.moving_layers[_i].id == _layer) return;
    var _h = layer_get_hspeed(_layer), _v = layer_get_vspeed(_layer);
    if (_h == 0 && _v == 0) return;
    array_push(_t.moving_layers, {id:_layer, hspeed:_h, vspeed:_v, held:false});
}

function timing_layers_step(_hold = false) {
    var _t = global.tcc_timing;
    if (_t.layer_room_id != room) {
        _t.layer_room_id = room;
        _t.moving_layers = [];
        var _layers = layer_get_all();
        if (is_array(_layers)) for (var _l = 0; _l < array_length(_layers); ++_l)
            timing_register_layer(_layers[_l]);
    }
    for (var _i = 0; _i < array_length(_t.moving_layers); ++_i) {
        var _n = _t.moving_layers[_i];
        if (!layer_exists(_n.id)) continue;
        if (_hold || !_t.tick) {
            if (_n.held) continue;
            _n.hspeed = layer_get_hspeed(_n.id); _n.vspeed = layer_get_vspeed(_n.id);
            layer_hspeed(_n.id, 0); layer_vspeed(_n.id, 0);
            _n.held = true;
        } else if (_n.held) {
            layer_hspeed(_n.id, _n.hspeed); layer_vspeed(_n.id, _n.vspeed);
            _n.held = false;
        }
    }
}

function timing_room_start() {
    timing_boot();
    var _t = global.tcc_timing;
    _t.room_generation += 1;
    // Authored instance IDs are reused on restart. Membership from the old
    // room must not resolve to fresh instances without their timing state.
    // Persistent instances retain their own state and rejoin the active scan.
    _t.tracked = [];
    ds_map_clear(_t.tracked_set);
    _t.pending = [];
    _t.room_id = noone;
    _t.activation_dirty = true;
    _t.layer_room_id = noone;
    _t.cameras = [];
    // Loading and Room Start run outside the new room's gameplay timeline.
    // They must not leave a debt that speeds through the opening ticks.
    _t.clock_us = get_timer();
    _t.accumulator_us = 0;
    _t.first = true;
    _t.begin_pending = true;
    _t.draw_accumulator_us = 1000000 / global.renderfps;
    timing_apply_render_rate();
    // A partial room-entry frame must not advance scenery before the first
    // complete Begin boundary of the new room's simulation timeline.
    timing_layers_step(true);
    timing_sequence_room_start();
    credits_windblown_init();
}

function timing_refresh_active(_settled = false) {
    var _t = global.tcc_timing;
    if (!_t.activation_dirty && _t.room_id == room) return;
    // A Begin scan can precede activation's native event-end commit. Keep the
    // flag until a later Step/End boundary has actually observed that commit.
    _t.activation_dirty = !_settled;
    _t.room_id = room;
    // Activation/deactivation is deferred to the end of its native event.
    // The following phase discovers actual active instances, including ones
    // without Step events. Frequent region calls coalesce into this scan.
    with (all) {
        timing_instance_register_now();
        if (variable_instance_exists(id, "timing_native")) {
            if (timing_is_tick()) timing_instance_resume(); else timing_instance_hold();
        }
    }
}

function timing_activate_object(_object) {
    instance_activate_object(_object);
    if (variable_global_exists("tcc_timing")) {
        global.tcc_timing.activation_dirty = true;
        // A scheduled instance is addressable before with(all) discovers it.
        // Queue its exact ID for the pre-alarm flush; object-wide activation
        // remains in the coalesced scan for the subsequent native boundary.
        if (!object_exists(_object) && instance_exists(_object)) timing_register_instance(_object);
    }
}
function timing_activate_region(_left, _top, _width, _height, _inside) {
    instance_activate_region(_left, _top, _width, _height, _inside);
    if (variable_global_exists("tcc_timing")) global.tcc_timing.activation_dirty = true;
}
function timing_activate_all() {
    instance_activate_all();
    if (variable_global_exists("tcc_timing")) global.tcc_timing.activation_dirty = true;
}

function timing_create_depth(_x, _y, _depth, _object, _variables = undefined) {
    var _id = is_undefined(_variables) ? instance_create_depth(_x, _y, _depth, _object)
        : instance_create_depth(_x, _y, _depth, _object, _variables);
    timing_register_instance(_id);
    return _id;
}
function timing_create_layer(_x, _y, _layer, _object, _variables = undefined) {
    var _id = is_undefined(_variables) ? instance_create_layer(_x, _y, _layer, _object)
        : instance_create_layer(_x, _y, _layer, _object, _variables);
    timing_register_instance(_id);
    return _id;
}

function timing_instance_hold() {
    var _n = timing_native;
    if (!_n.held) {
        _n.speed = speed; _n.direction = direction; _n.gravity = gravity;
        _n.hspeed = hspeed; _n.vspeed = vspeed;
        _n.friction = friction; _n.path_speed = path_speed; _n.image_speed = image_speed;
        _n.held = true;
    } else {
        // A caller may finish native property initialization after Create.
        if (speed != 0) {
            _n.speed = speed; _n.direction = direction;
            _n.hspeed = hspeed; _n.vspeed = vspeed;
        }
        if (gravity != 0) _n.gravity = gravity;
        if (friction != 0) _n.friction = friction;
        if (path_speed != 0) _n.path_speed = path_speed;
        if (image_speed != 0) _n.image_speed = image_speed;
    }
    speed = 0; gravity = 0; friction = 0; path_speed = 0; image_speed = 0;
    // A zero alarm is not promoted: doing so would fire an event that the
    // normal engine would discard when decrementing zero to minus one.
    if (_n.alarm_render != timing_render_id() && !global.tcc_timing.alarm_phase_passed) {
        _n.alarm_render = timing_render_id();
        for (var _a = 0; _a < 12; ++_a) if (alarm[_a] > 0) alarm[_a] += 1;
    }
}

function timing_instance_resume() {
    var _n = timing_native;
    if (!_n.held) return;
    if (_n.speed > 0) {
        // Rebuilding a native positive vector from its rounded angle on every
        // skipped frame accumulates drift. Preserve the engine's exact vector.
        hspeed = _n.hspeed; vspeed = _n.vspeed;
    } else {
        // Vector setters canonicalize a negative speed. Signed motion and the
        // otherwise meaningful zero-speed direction retain their native form.
        // Avoid regenerating an unchanged zero vector: its residual native
        // components are state too. Only this comparison disables epsilon.
        var _resume_epsilon = math_get_epsilon();
        math_set_epsilon(0);
        var _same_zero_motion = _n.speed == 0 && speed == _n.speed
            && direction == _n.direction && hspeed == _n.hspeed && vspeed == _n.vspeed;
        math_set_epsilon(_resume_epsilon);
        if (!_same_zero_motion) {
            direction = _n.direction;
            speed = _n.speed;
        }
    }
    gravity = _n.gravity; friction = _n.friction;
    path_speed = _n.path_speed; image_speed = _n.image_speed;
    // Preserve what the Cartesian setters actually produced. Scalar-owning
    // actors can restore their saved polar values before their own arithmetic
    // only while no intervening Alarm/caller has changed this native state.
    _n.resume_tick_id = timing_tick_id();
    _n.resume_speed = speed; _n.resume_direction = direction;
    _n.resume_hspeed = hspeed; _n.resume_vspeed = vspeed;
    _n.held = false;
}

function timing_restore_polar_motion() {
    if (!variable_global_exists("tcc_timing") || !timing_is_tick()
        || !variable_instance_exists(id, "timing_native")) return;
    var _n = timing_native;
    if (_n.resume_tick_id != timing_tick_id()) return;
    _n.resume_tick_id = -1;
    if (_n.speed <= 0 || speed != _n.resume_speed || direction != _n.resume_direction
        || hspeed != _n.resume_hspeed || vspeed != _n.resume_vspeed) return;
    // The player's zero-G branch rewrites native speed every positive tick.
    // Restore the exact pre-hold scalar/angle before thrust/braking reads it;
    // generic vector-only bodies retain the Cartesian restoration above.
    direction = _n.direction;
    speed = _n.speed;
}

function timing_instance_step() {
    if (!variable_global_exists("tcc_timing")) return true;
    global.tcc_timing.alarm_phase_passed = true;
    timing_instance_register_now();
    if (!variable_instance_exists(id, "timing_native")) {
        // A previously stationary actor can start native motion or an alarm
        // inside this Step. Discover those final fields at the End boundary,
        // before the next frame's alarms, without changing its first motion.
        if (timing_is_tick()) timing_register_instance(id);
        return timing_is_tick();
    }
    if (timing_is_tick()) timing_instance_resume(); else timing_instance_hold();
    return timing_is_tick();
}

function timing_flush_pending() {
    var _t = global.tcc_timing;
    var _pending = _t.pending;
    _t.pending = [];
    for (var _i = 0; _i < array_length(_pending); ++_i) {
        if (!instance_exists(_pending[_i])) continue;
        with (_pending[_i]) {
            timing_instance_register_now();
            if (variable_instance_exists(id, "timing_native")) {
                if (timing_is_tick()) timing_instance_resume(); else timing_instance_hold();
            }
        }
    }
}

function timing_begin_step() {
    timing_boot();
    var _t = global.tcc_timing;
    if (!_t.begin_pending) return;
    _t.begin_pending = false;
    timing_camera_restore();
    _t.alarm_phase_passed = false;
    _t.render_id += 1;
    var _now = get_timer();
    _t.elapsed_us = max(0, _now - _t.clock_us);
    _t.clock_us = _now;
    var _tick_us = 1000000 / TCC_SIM_HZ;
    var _interrupted = os_is_paused();
    _t.interrupt_pending |= _interrupted;
    var _background_boundary = _interrupted && (platform_mobile()
        || (variable_global_exists("autopausesettings") && global.autopausesettings == 1));
    _t.clock_pause_applied = _t.pause_clock;
    _t.clock_resume_applied = _t.resume_boundary;
    _t.clock_background_applied = _background_boundary;
    _t.clock_accumulator_before_us = _t.accumulator_us;
    if (_t.first) { _t.first = false; _t.accumulator_us = 1000000 / TCC_SIM_HZ; }
    else if (_t.pause_clock || _t.resume_boundary || _background_boundary) {
        // Paused and OS-suspended time belongs to the session wall clock.
        // It cannot become a burst of gameplay after the player resumes.
        _t.accumulator_us = min(_tick_us, _t.accumulator_us + min(_t.elapsed_us, _tick_us));
    } else _t.accumulator_us += _t.elapsed_us;
    if (_t.clock_resume_applied && _t.interrupt_serial > _t.consumed_interrupt_serial) {
        _t.consumed_interrupt_serial = _t.interrupt_serial;
        _t.interrupt_consumption = {serial:_t.interrupt_serial,
            renderId:_t.render_id, tickId:_t.tick_id, elapsedUs:_t.elapsed_us,
            accumulatorBeforeUs:_t.clock_accumulator_before_us, accumulatorBoundedUs:_t.accumulator_us,
            limitUs:_tick_us, previousPauseApplied:_t.clock_pause_applied};
    }
    _t.resume_boundary = _background_boundary;
    _t.tick = _t.accumulator_us + 0.0001 >= _tick_us;
    if (_t.tick) {
        _t.accumulator_us = max(0, _t.accumulator_us - _tick_us);
        _t.tick_id += 1;
        if (!variable_global_exists("troop_nav_step")) global.troop_nav_step = 0;
        global.troop_nav_step += 1;
    }
    global.delta = _t.tick ? 1 : 0;
    // Start an isolated probe at a complete native Begin boundary. A room
    // created during a previous engine frame can have an initial partial End.
    if ((TCC_GAMEPLAY_QA || TCC_SELF_CHECK) && _t.tick
        && variable_global_exists("timing_qa_pending_spec")
        && is_struct(global.timing_qa_pending_spec)
        && timing_tick_id() >= global.timing_qa_ready_after_tick) {
        var _probe_spec = global.timing_qa_pending_spec;
        global.timing_qa_pending_spec = undefined;
        var _setup_start = get_timer();
        timing_qa_setup(_probe_spec);
        // Opt-in calibration setup (including native sprite duplication) is
        // outside its recorded input timeline. Production rooms never use it.
        _t.clock_us = get_timer();
        _t.accumulator_us = 0;
        _t.elapsed_us = 0;
        _t.draw_accumulator_us = 1000000 / global.renderfps;
        var _preparation = global.tcc_qa.preparation;
        _preparation.setupElapsedUs = _t.clock_us - _setup_start;
        _preparation.warmupElapsedUs = _setup_start - _preparation.startedUs;
        _preparation.scenarioStartTick = timing_tick_id();
        _preparation.accumulatorResetUs = _t.clock_us;
        _preparation.recordedFramesBeforeSetup = global.tcc_qa.frame;
        _preparation.complete = true;
        global.tcc_qa.preparing = false;
    }
    // Opt-in default-follow stimulus setup belongs to a complete native
    // Begin after the normal floor/player exist, before any recorded input.
    if (TCC_GAMEPLAY_QA && _t.tick && qa_active()
        && is_struct(qa_value(global.tcc_qa, "camera_follow_pending_spec", undefined))) {
        var _follow_setup_spec = global.tcc_qa.camera_follow_pending_spec;
        global.tcc_qa.camera_follow_pending_spec = undefined;
        camera_follow_qa_setup(_follow_setup_spec);
        _t.clock_us = get_timer(); _t.accumulator_us = 0; _t.elapsed_us = 0;
        _t.draw_accumulator_us = 1000000 / global.renderfps;
    }
    timing_layers_step();
    timing_refresh_active(true);
    timing_flush_pending();
    var _live = [];
    for (var _i = 0; _i < array_length(_t.tracked); ++_i) {
        var _id = _t.tracked[_i];
        if (!instance_exists(_id) || !variable_instance_exists(_id, "timing_native")) {
            ds_map_delete(_t.tracked_set, _id);
            continue;
        }
        array_push(_live, _id);
        with (_id) {
            if (_t.tick) {
                timing_instance_resume();
                timing_native.start_x = x; timing_native.start_y = y;
            } else timing_instance_hold();
        }
    }
    _t.tracked = _live;
    timing_input_capture();
    _t.draw_accumulator_us += _t.elapsed_us;
    var _draw_us = 1000000 / global.renderfps;
    _t.draw_frame = _t.draw_accumulator_us + 0.0001 >= _draw_us;
    if (_t.draw_frame) _t.draw_accumulator_us = _t.draw_accumulator_us mod _draw_us;
    // Catch up active-room time through additional ordinary native frames.
    // Only explicit scene/pause boundaries reset debt; events never emulate a
    // second native physics step.
    var _base_rate = max(TCC_SIM_HZ, global.renderfps);
    var _rate = _t.accumulator_us >= _tick_us ? min(1000, max(120, _base_rate * 2)) : _base_rate;
    if (_rate != _t.native_rate) { _t.native_rate = _rate; game_set_speed(_rate, gamespeed_fps); }
    timing_sequence_begin();
    credits_presentation_qa_begin();
    sequence_probe_qa_begin();
    // Present at the requested cadence even while simulation owes a tick.
    // Vsync-limited devices may never drain that debt completely; suppressing
    // every Draw in that case leaves a frozen screen while gameplay advances.
    draw_enable_drawevent(_t.draw_frame);
    timing_qa_observe();
    // Begin observers/input may reactivate an actor. Hold it before the native
    // alarm phase, rather than waiting until ordinary Step has already passed.
    timing_refresh_active();
    timing_flush_pending();
    timing_qa_before_native("root-begin-after-flush");
    camera_qa_sample("root-begin");
    camera_follow_qa_sample("root-begin");
    sequence_qa_sample("root-begin");
    sequence_probe_qa_sample("root-begin");
    credits_windblown_qa_observe("root-begin");
}

function timing_end_step() {
    if (!variable_global_exists("tcc_timing")) return;
    var _t = global.tcc_timing;
    if (_t.ended_render == _t.render_id) return;
    _t.ended_render = _t.render_id;
    _t.alarm_phase_passed = true;
    timing_refresh_active(true);
    timing_flush_pending();
    timing_gameplay_end_step();
    if (_t.tick) timing_buttons_end_step();
    // Controls created by UI modals cannot consume the edge that opened them.
    if (_t.tick) timing_ui_end_step();
    if (_t.tick) {
        for (var _i = 0; _i < array_length(_t.tracked); ++_i) {
            if (!instance_exists(_t.tracked[_i])) continue;
            with (_t.tracked[_i]) {
                if (!variable_instance_exists(id, "timing_native")) continue;
                var _n = timing_native;
                _n.previous_x = _n.start_x; _n.previous_y = _n.start_y;
                _n.current_x = x; _n.current_y = y;
            }
        }
        timing_input_clear();
    }
    timing_camera_end_step();
    credits_windblown_tick();
    timing_qa_after_step();
    _t.pause_clock = variable_global_exists("pause") && global.pause != 0;
    camera_qa_sample("root-end");
    camera_follow_qa_sample("root-end");
    timing_sequence_end();
    sequence_qa_sample("root-end");
    sequence_probe_qa_sample("root-end");
    sequence_probe_qa_end();
    credits_windblown_qa_observe("root-end");
    credits_presentation_qa_end();
    _t.begin_pending = true;
}

function timing_interpolates_instance() {
    if (object_index == o_parentandroidbutton || object_is_ancestor(object_index, o_parentandroidbutton)) return false;
    if (object_index == o_smoothcamera || object_index == o_smoothcameraboss5
        || object_index == o_gunequipped || object_index == o_fire) return true;
    if (object_index == o_torch && (holding || died)) return true;
    return variable_instance_exists(id, "hsp") || variable_instance_exists(id, "vsp") || speed != 0
        || (variable_instance_exists(id, "timing_native") && timing_native.speed != 0);
}

function timing_before_draw() {
    if (!variable_global_exists("tcc_timing")) return;
    var _t = global.tcc_timing;
    _t.drawn_frames += 1;
    var _now = get_timer();
    _t.draw_seconds = _t.last_draw_us == 0 ? 1 / global.renderfps : min(0.1, (_now - _t.last_draw_us) / 1000000);
    _t.last_draw_us = _now;
    if (qa_active() && global.tcc_qa.running && (global.tcc_qa.started || credits_presentation_qa_clock_started()) && !global.tcc_qa.finished) {
        var _q = global.tcc_qa;
        _q.render_frames += 1;
        array_push(_q.render_frame_deltas, _now - _q.render_us);
        _q.render_us = _now;
    }
    if (global.renderfps <= TCC_SIM_HZ) return;
    var _alpha = clamp(_t.accumulator_us * TCC_SIM_HZ / 1000000, 0, 1);
    for (var _i = 0; _i < array_length(_t.tracked); ++_i) {
        if (!instance_exists(_t.tracked[_i])) continue;
        with (_t.tracked[_i]) {
            if (!variable_instance_exists(id, "timing_native")) continue;
            if (!timing_interpolates_instance()) continue;
            var _n = timing_native;
            // Teleports and scene transitions must not smear through walls.
            if (point_distance(_n.previous_x, _n.previous_y, x, y) > 64) continue;
            _n.draw_x = x; _n.draw_y = y; _n.interpolated = true;
            x = lerp(_n.previous_x, _n.current_x, _alpha);
            y = lerp(_n.previous_y, _n.current_y, _alpha);
        }
    }
    timing_camera_before_draw(_alpha);
}

function timing_after_draw() {
    timing_camera_restore();
    if (!variable_global_exists("tcc_timing")) return;
    var _t = global.tcc_timing;
    for (var _i = 0; _i < array_length(_t.tracked); ++_i) {
        if (!instance_exists(_t.tracked[_i])) continue;
        with (_t.tracked[_i]) {
            if (!variable_instance_exists(id, "timing_native")) continue;
            var _n = timing_native;
            if (!_n.interpolated) continue;
            x = _n.draw_x; y = _n.draw_y; _n.interpolated = false;
        }
    }
}
