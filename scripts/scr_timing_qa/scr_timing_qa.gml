/// Native timing diagnostics. These functions observe engine events; they never
/// dispatch an event, emulate motion, change the requested FPS, or assert PASS.
/// Integration: setup once in an isolated empty room, observe before the final
/// Begin flush, before_native after each named controller Begin/Step flush, and
/// after_step after native motion/collisions in root End Step.
/// Probe Begin/End remain unguarded observers. Main's production guards cover
/// the probe/partner Step, Alarm, Collision, and Animation End event bodies.
function timing_qa_active() {
    return (TCC_GAMEPLAY_QA || TCC_SELF_CHECK) && variable_global_exists("timing_qa")
        && is_struct(global.timing_qa) && global.timing_qa.active;
}

function timing_qa_value(_record, _key, _fallback) {
    return is_struct(_record) && variable_struct_exists(_record, _key)
        ? variable_struct_get(_record, _key) : _fallback;
}

function timing_qa_integer(_spec, _key, _fallback, _minimum, _maximum) {
    var _value = timing_qa_value(_spec, _key, _fallback);
    if (!is_numeric(_value) || is_nan(_value) || is_infinity(_value)
        || _value != floor(_value) || _value < _minimum || _value > _maximum)
        throw "Native timing QA invalid " + _key;
    return _value;
}

function timing_qa_stamp(_phase) {
    var _qa = global.timing_qa;
    var _timing = variable_global_exists("tcc_timing") ? global.tcc_timing : undefined;
    return {phase:_phase, outerSequence:_qa.outer_sequence,
        renderId:timing_render_id(), tickId:timing_tick_id(), isTick:timing_is_tick(),
        relativeTick:timing_tick_id() - _qa.start_tick, paused:global.pause != 0,
        generatedDrawFrames:timing_qa_value(_timing, "drawn_frames", undefined),
        drawScheduled:timing_qa_value(_timing, "draw_frame", undefined),
        centralBeginPending:timing_qa_value(_timing, "begin_pending", undefined),
        rootEndAlreadyObserved:_qa.last_after_render == timing_render_id(),
        nativeOuterHz:game_get_speed(gamespeed_fps),
        elapsedUs:get_timer() - _qa.started_us};
}

function timing_qa_instance_state(_who) {
    if (!instance_exists(_who)) {
        var _qa = global.timing_qa;
        if (_who == _qa.nostep_instance && _qa.nostep_maybe_inactive && !_qa.nostep_destroyed) {
            // Retained native ID access is tested, not assumed. Inactive
            // instances cannot be observed with with(instance). A native
            // failure remains explicit evidence and prevents acceptance.
            try {
                return {present:false, active:false, inactiveReadSucceeded:true,
                    role:_who.timingqa_role, instanceId:_who,
                    x:_who.x, y:_who.y, speed:_who.speed, direction:_who.direction,
                    gravity:_who.gravity, friction:_who.friction,
                    imageIndex:_who.image_index, imageSpeed:_who.image_speed,
                    alarm0:_who.alarm[0], path:_who.path_index,
                    pathPosition:_who.path_position, pathSpeed:_who.path_speed,
                    stepEvents:_who.timingqa_step_count, alarmEvents:_who.timingqa_alarm_count,
                    animationEndEvents:_who.timingqa_animation_count,
                    rawAlarmEntries:_who.timingqa_raw_alarm_count,
                    rawAnimationEndEntries:_who.timingqa_raw_animation_count};
            } catch (_error) {
                var _failure = timing_qa_stamp("inactive-read-failure");
                _failure.instanceId = _who;
                _failure.error = timing_qa_value(_error, "message", string(_error));
                if (array_length(_qa.inactive_read_errors) < _qa.max_samples)
                    array_push(_qa.inactive_read_errors, _failure);
                return {present:false, active:false, instanceId:_who, inactiveReadSucceeded:false};
            }
        }
        return {present:false, active:false, instanceId:_who};
    }
    var _result = undefined;
    with (_who) {
        _result = {present:true, active:true, role:timingqa_role, instanceId:id,
            x:x, y:y, xprevious:xprevious, yprevious:yprevious,
            speed:speed, direction:direction, hspeed:hspeed, vspeed:vspeed,
            gravity:gravity, gravityDirection:gravity_direction, friction:friction,
            imageIndex:image_index, imageSpeed:image_speed,
            imageXscale:image_xscale, imageYscale:image_yscale, imageAngle:image_angle,
            sprite:sprite_index, mask:mask_index,
            spriteFrames:sprite_exists(sprite_index) ? sprite_get_number(sprite_index) : 0,
            spriteSpeed:sprite_exists(sprite_index) ? sprite_get_speed(sprite_index) : 0,
            spriteSpeedType:sprite_exists(sprite_index) ? sprite_get_speed_type(sprite_index) : -1,
            alarm0:alarm[0], path:path_index, pathPosition:path_position, pathSpeed:path_speed,
            beginEvents:timingqa_begin_count, stepEvents:timingqa_step_count,
            endEvents:timingqa_end_count, alarmEvents:timingqa_alarm_count,
            collisionEvents:timingqa_collision_count, animationEndEvents:timingqa_animation_count,
            rawAlarmEntries:timingqa_raw_alarm_count, rawAnimationEndEntries:timingqa_raw_animation_count,
            birthTick:timingqa_birth_tick, birthRender:timingqa_birth_render,
            birthOuterSequence:timingqa_birth_outer, birthIsTick:timingqa_birth_is_tick};
    }
    return _result;
}

function timing_qa_sample_instance(_phase, _who) {
    if (!timing_qa_active()) return;
    var _qa = global.timing_qa;
    if (array_length(_qa.samples) >= _qa.max_samples) {
        _qa.samples_truncated = true;
        _qa.dropped_samples += 1;
        return;
    }
    var _sample = timing_qa_stamp(_phase);
    _sample.state = timing_qa_instance_state(_who);
    array_push(_qa.samples, _sample);
}

function timing_qa_event(_kind, _who, _detail = undefined) {
    if (!timing_qa_active()) return;
    var _qa = global.timing_qa;
    if (array_length(_qa.events) >= _qa.max_samples) {
        _qa.events_truncated = true;
        _qa.dropped_events += 1;
        return;
    }
    var _event = timing_qa_stamp(_kind);
    _event.state = timing_qa_instance_state(_who);
    _event.detail = _detail;
    array_push(_qa.events, _event);
}

function timing_qa_native_entry(_kind, _who) {
    if (!timing_qa_active()) return;
    var _qa = global.timing_qa;
    if (array_length(_qa.native_entries) >= _qa.max_samples) {
        _qa.events_truncated = true;
        _qa.dropped_events += 1;
        return;
    }
    var _event = timing_qa_stamp(_kind);
    _event.state = timing_qa_instance_state(_who);
    array_push(_qa.native_entries, _event);
}

// Optional native layer motion observation. Setup supplies real layer speeds;
// subsequent samples only read the engine's actual offsets and properties.
function timing_qa_layers_setup() {
    var _qa = global.timing_qa;
    if (timing_qa_value(_qa.spec, "observeLayers", false) != true) return;
    var _definitions = [
        {role:"horizontal-negative", x:32, y:-4096, h:-0.2, v:0},
        {role:"vertical-positive", x:96, y:-4096, h:0, v:1},
        {role:"diagonal", x:160, y:-4096, h:0.2, v:-0.5}
    ];
    for (var _i = 0; _i < array_length(_definitions); ++_i) {
        var _definition = _definitions[_i];
        var _layer = layer_create(10000 + _i, "TCC_TimingQA_" + _definition.role);
        layer_background_create(_layer, s_redblock);
        layer_x(_layer, _definition.x); layer_y(_layer, _definition.y);
        layer_hspeed(_layer, _definition.h); layer_vspeed(_layer, _definition.v);
        timing_register_layer(_layer);
        array_push(_qa.owned_layers, {id:_layer, role:_definition.role,
            initialX:_definition.x, initialY:_definition.y, hspeed:_definition.h, vspeed:_definition.v});
    }
    timing_qa_layers_sample("layer-setup");
}

function timing_qa_layers_sample(_phase) {
    if (!timing_qa_active()) return;
    var _qa = global.timing_qa;
    if (array_length(_qa.owned_layers) == 0) return;
    if (array_length(_qa.layer_samples) >= _qa.max_samples) {
        _qa.layer_samples_truncated = true;
        return;
    }
    var _sample = timing_qa_stamp(_phase);
    _sample.layers = [];
    for (var _i = 0; _i < array_length(_qa.owned_layers); ++_i) {
        var _definition = _qa.owned_layers[_i];
        var _present = layer_exists(_definition.id);
        array_push(_sample.layers, {role:_definition.role, id:_definition.id, present:_present,
            x:_present ? layer_get_x(_definition.id) : undefined,
            y:_present ? layer_get_y(_definition.id) : undefined,
            hspeed:_present ? layer_get_hspeed(_definition.id) : undefined,
            vspeed:_present ? layer_get_vspeed(_definition.id) : undefined});
    }
    array_push(_qa.layer_samples, _sample);
}

function timing_qa_sprite(_name, _speed, _type) {
    var _qa = global.timing_qa;
    var _sprite = sprite_duplicate(s_playerdead);
    if (!sprite_exists(_sprite)) throw "Native timing QA sprite duplicate failed";
    array_push(_qa.owned_sprites, _sprite);
    sprite_set_speed(_sprite, _speed, _type);
    var _record = {name:_name, sprite:_sprite, source:"s_playerdead",
        frames:sprite_get_number(_sprite), requestedSpeed:_speed, requestedType:_type,
        beforeSpeed:sprite_get_speed(_sprite), beforeType:sprite_get_speed_type(_sprite)};
    // Exercise the production dynamic-sprite hook, not a fixture substitute.
    timing_normalize_sprite(_sprite);
    _record.afterSpeed = sprite_get_speed(_sprite);
    _record.afterType = sprite_get_speed_type(_sprite);
    array_push(_qa.animations, _record);
    return _sprite;
}

function timing_qa_spawn(_role, _x, _y, _partner = false, _nostep = false) {
    var _qa = global.timing_qa;
    var _object = _nostep ? o_timing_qa_nostep : (_partner ? o_timing_qa_partner : o_timing_qa_probe);
    var _who = timing_create_depth(_x, _y, -100000, _object, {timingqa_role:_role});
    if (!instance_exists(_who)) throw "Native timing QA actor creation failed: " + _role;
    array_push(_qa.owned_instances, _who);
    // timing_create_depth queued registration. Caller initialization is still
    // legal here; only the controller's later flush is a freeze boundary.
    timing_qa_sample_instance("created-registration-queued", _who);
    return _who;
}

function timing_qa_cleanup() {
    if (!variable_global_exists("timing_qa") || !is_struct(global.timing_qa)) return true;
    var _qa = global.timing_qa;
    _qa.active = false;
    if (_qa.nostep_maybe_inactive && !_qa.nostep_destroyed && !instance_exists(_qa.nostep_instance)) {
        // Native activation completes at event end. Retain every owned asset
        // until the next ordinary outer frame can actually destroy the actor.
        _qa.cleanup_pending = true;
        timing_activate_object(_qa.nostep_instance);
        return false;
    }
    _qa.cleanup_pending = false;
    _qa.nostep_maybe_inactive = false;
    for (var _i = 0; _i < array_length(_qa.owned_instances); ++_i) {
        var _who = _qa.owned_instances[_i];
        if (instance_exists(_who)) with (_who) instance_destroy();
    }
    if (_qa.owned_path >= 0 && path_exists(_qa.owned_path)) path_delete(_qa.owned_path);
    for (var _s = 0; _s < array_length(_qa.owned_sprites); ++_s) {
        var _sprite = _qa.owned_sprites[_s];
        if (sprite_exists(_sprite)) sprite_delete(_sprite);
    }
    _qa.owned_instances = [];
    _qa.owned_sprites = [];
    _qa.owned_path = -1;
    for (var _l = 0; _l < array_length(_qa.owned_layers); ++_l)
        if (layer_exists(_qa.owned_layers[_l].id)) layer_destroy(_qa.owned_layers[_l].id);
    _qa.owned_layers = [];
    return true;
}

function timing_qa_setup(_spec = undefined) {
    if (!TCC_GAMEPLAY_QA && !TCC_SELF_CHECK) return undefined;
    if (!is_undefined(_spec) && !is_struct(_spec)) throw "Native timing QA requires a spec struct";
    var _ticks = timing_qa_integer(_spec, "ticks", 72, 60, 240);
    var _max_outer = timing_qa_integer(_spec, "maxOuterFrames", 2400, 240, 6000);
    var _max_samples = timing_qa_integer(_spec, "maxSamples", 30000, 1000, 100000);
    if (!timing_qa_cleanup()) throw "Native timing QA cleanup requires the next native outer frame";
    global.timing_qa = {active:true, schemaVersion:2, fixture:"native-fixed-tick-v2",
        spec:_spec, nativeRoom:room_get_name(room), start_tick:timing_tick_id(),
        start_render:timing_render_id(), started_us:get_timer(), target_ticks:_ticks,
        max_outer:_max_outer, max_samples:_max_samples, outer_sequence:0,
        last_outer_render:undefined, last_after_render:undefined, observed_through_tick:-1,
        outer_hook_duplicate_count:0, after_hook_duplicate_count:0, after_hook_missing_begin_count:0,
        skipped_outer_count:0, tick_outer_count:0, samples:[], events:[], native_entries:[], animations:[],
        inactive_read_errors:[], post_flush_hooks:{}, post_flush_hook_counts:{}, post_flush_duplicates:0,
        nostep_instance:noone, nostep_stage:0, nostep_maybe_inactive:false, nostep_destroyed:false,
        nostep_reactivated_on_skip:false, cleanup_pending:false, lifecycle_actions:[],
        owned_instances:[], owned_sprites:[], owned_path:-1, late_instance:noone,
        owned_layers:[], layer_samples:[], layer_samples_truncated:false,
        late_pending:true, late_created_on_skip:false, late_creation_tick:undefined,
        samples_truncated:false, events_truncated:false, dropped_samples:0, dropped_events:0,
        outer_limit_reached:false, setup_render_cap:variable_global_exists("renderfps") ? global.renderfps : undefined,
        setup_gameplay_hz:variable_global_exists("maxfps") ? global.maxfps : undefined,
        setup_native_outer_hz:game_get_speed(gamespeed_fps)};
    var _qa = global.timing_qa;
    try {
        _qa.fps_sprite = timing_qa_sprite("fps-origin", 15, spritespeed_framespersecond);
        _qa.frame_sprite = timing_qa_sprite("frame-origin", 0.25, spritespeed_framespergameframe);
        _qa.owned_path = path_add();
        path_set_kind(_qa.owned_path, 0);
        path_set_closed(_qa.owned_path, true);
        path_add_point(_qa.owned_path, 0, 0, 100);
        path_add_point(_qa.owned_path, 24, 0, 100);
        path_add_point(_qa.owned_path, 24, -24, 100);
        path_add_point(_qa.owned_path, 0, -24, 100);
        timing_qa_spawn("signed-negative", 160, 160);
        timing_qa_spawn("zero-direction", 400, 160);
        timing_qa_spawn("diagonal", 640, 160);
        timing_qa_spawn("positive-alarm", 880, 160);
        timing_qa_spawn("animation-fps-origin", 160, 400);
        timing_qa_spawn("animation-frame-origin", 400, 400);
        timing_qa_spawn("native-path", 640, 400);
        timing_qa_spawn("partner-moving", 500, 560, true);
        timing_qa_spawn("partner-overlap", 700, 560, true);
        timing_qa_spawn("collision-moving", 476, 574);
        timing_qa_spawn("collision-overlap", 708, 568);
        _qa.nostep_instance = timing_qa_spawn("native-no-step", 880, 560, false, true);
        timing_qa_layers_setup();
    } catch (_error) {
        timing_qa_cleanup();
        throw _error;
    }
    return {fixture:_qa.fixture, targetTicks:_ticks, actors:array_length(_qa.owned_instances),
        animations:_qa.animations,
        hookOrder:"observe before final Begin flush; before_native after named Begin/Step flush; after_step after native motion"};
}

/// Root Begin hook. This is a native-frame observation, not an event dispatch.
function timing_qa_observe() {
    if (variable_global_exists("timing_qa") && is_struct(global.timing_qa)
        && global.timing_qa.cleanup_pending) timing_qa_cleanup();
    if (!timing_qa_active()) return;
    var _qa = global.timing_qa, _render = timing_render_id();
    if (!is_undefined(_qa.last_outer_render) && _qa.last_outer_render == _render) {
        _qa.outer_hook_duplicate_count += 1;
        return;
    }
    _qa.last_outer_render = _render;
    _qa.outer_sequence += 1;
    if (timing_is_tick()) {
        _qa.tick_outer_count += 1;
    } else {
        _qa.skipped_outer_count += 1;
    }
    if (_qa.outer_sequence > _qa.max_outer) {
        _qa.outer_limit_reached = true;
        return;
    }
    var _age = timing_tick_id() - _qa.start_tick;
    if (_qa.late_pending && ((!timing_is_tick() && _age >= 3)
        || (timing_is_tick() && _age >= 4))) {
        // A skip after tick3 exercises asynchronous creation. If that cadence
        // has no skip in this window, tick4 is the native control instead.
        // Every cap therefore observes its first logical movement on tick4;
        // the verifier requires a genuine skipped trial from at least one cap.
        _qa.late_pending = false;
        _qa.late_created_on_skip = !timing_is_tick();
        _qa.late_creation_tick = timing_tick_id();
        _qa.late_instance = timing_qa_spawn("late-created", 880, 400);
        var _zero = timing_qa_spawn("late-zero-overrides", 1040, 400);
        // These are caller assignments after the production wrapper returns.
        // They must not be replaced by the actor's earlier Create defaults.
        _zero.speed = 0;
        _zero.gravity = 0;
        _zero.friction = 0;
        _zero.path_speed = 0;
        _zero.image_speed = 0;
        _zero.alarm[0] = 0;
        _zero.direction = 271;
        timing_qa_sample_instance("caller-final-zero-overrides", _zero);
        var _direction = timing_qa_spawn("late-direction-override", 1200, 400);
        _direction.direction = 271;
        timing_qa_sample_instance("caller-final-direction-override", _direction);
    }
    if (_qa.nostep_stage == 0 && timing_is_tick() && _age >= 8) {
        var _deactivate = timing_qa_stamp("native-deactivation-request");
        _deactivate.state = timing_qa_instance_state(_qa.nostep_instance);
        array_push(_qa.lifecycle_actions, _deactivate);
        _qa.nostep_stage = 1;
        _qa.nostep_maybe_inactive = true;
        instance_deactivate_object(_qa.nostep_instance);
    } else if (_qa.nostep_stage == 1 && ((!timing_is_tick() && _age >= 16)
        || (timing_is_tick() && _age >= 17))) {
        var _activate = timing_qa_stamp("native-reactivation-request");
        _activate.state = timing_qa_instance_state(_qa.nostep_instance);
        array_push(_qa.lifecycle_actions, _activate);
        _qa.nostep_stage = 2;
        _qa.nostep_reactivated_on_skip = !timing_is_tick();
        timing_activate_object(_qa.nostep_instance);
    }
    for (var _i = 0; _i < array_length(_qa.owned_instances); ++_i)
        timing_qa_sample_instance("root-before-final-begin-flush", _qa.owned_instances[_i]);
}

/// Observation only. Main names each actual post-flush hook; calling this
/// function never refreshes, flushes, compensates alarms, or dispatches events.
function timing_qa_before_native(_phase = "root-begin-after-flush") {
    if (!timing_qa_active()) return;
    if (!is_string(_phase) || string_length(_phase) == 0) throw "Native timing QA hook phase requires a name";
    var _qa = global.timing_qa, _render = timing_render_id();
    if (timing_qa_value(_qa.post_flush_hooks, _phase, -1) == _render) {
        _qa.post_flush_duplicates += 1;
        return;
    }
    variable_struct_set(_qa.post_flush_hooks, _phase, _render);
    variable_struct_set(_qa.post_flush_hook_counts, _phase,
        timing_qa_value(_qa.post_flush_hook_counts, _phase, 0) + 1);
    if (_qa.outer_sequence > _qa.max_outer) return;
    for (var _i = 0; _i < array_length(_qa.owned_instances); ++_i)
        timing_qa_sample_instance(_phase, _qa.owned_instances[_i]);
    timing_qa_layers_sample(_phase);
}

/// Root End hook: the authoritative after-motion snapshot. Native instance
/// Begin/End records expose event ordering but cannot substitute for this hook.
function timing_qa_after_step() {
    if (!timing_qa_active()) return;
    var _qa = global.timing_qa, _render = timing_render_id();
    if (!is_undefined(_qa.last_after_render) && _qa.last_after_render == _render) {
        _qa.after_hook_duplicate_count += 1;
        return;
    }
    _qa.last_after_render = _render;
    if (is_undefined(_qa.last_outer_render) || _qa.last_outer_render != _render)
        _qa.after_hook_missing_begin_count += 1;
    _qa.observed_through_tick = timing_tick_id();
    if (_qa.outer_sequence > _qa.max_outer) return;
    for (var _i = 0; _i < array_length(_qa.owned_instances); ++_i)
        timing_qa_sample_instance("root-after-native", _qa.owned_instances[_i]);
    timing_qa_layers_sample("root-after-native");
}

function timing_qa_actor_initialize() {
    timingqa_begin_count = 0;
    timingqa_step_count = 0;
    timingqa_end_count = 0;
    timingqa_alarm_count = 0;
    timingqa_collision_count = 0;
    timingqa_animation_count = 0;
    timingqa_raw_alarm_count = 0;
    timingqa_raw_animation_count = 0;
    timingqa_birth_tick = timing_tick_id();
    timingqa_birth_render = timing_render_id();
    timingqa_birth_outer = global.timing_qa.outer_sequence;
    timingqa_birth_is_tick = timing_is_tick();
    sprite_index = s_redparticle;
    mask_index = s_redparticle;
    image_index = 0;
    image_speed = 0;
    direction = 0;
    speed = 0;
    gravity = 0;
    gravity_direction = 270;
    friction = 0;
    alarm[0] = -1;
    switch (timingqa_role) {
        case "signed-negative":
            direction = 30; speed = -4; gravity = 0.125; friction = 0.05;
            break;
        case "zero-direction": direction = 123; break;
        case "diagonal":
            direction = 45; speed = 3; gravity = 0.1; friction = 0.025;
            break;
        case "positive-alarm": alarm[0] = 7; break;
        case "animation-fps-origin":
            sprite_index = global.timing_qa.fps_sprite; image_speed = 1;
            break;
        case "animation-frame-origin":
            sprite_index = global.timing_qa.frame_sprite; image_speed = 1;
            break;
        case "native-path":
            path_start(global.timing_qa.owned_path, 2, path_action_restart, false);
            break;
        case "collision-moving": speed = 2; break;
        case "late-created":
        case "late-direction-override":
            direction = 135; speed = -3; gravity = 0.2; friction = 0.075;
            sprite_index = global.timing_qa.fps_sprite; image_speed = 1; alarm[0] = 7;
            break;
        case "late-zero-overrides":
            direction = 135; speed = -3; gravity = 0.2; friction = 0.075;
            sprite_index = global.timing_qa.fps_sprite; image_speed = 1; alarm[0] = 7;
            path_start(global.timing_qa.owned_path, 2, path_action_restart, false);
            break;
        case "native-no-step":
            sprite_index = global.timing_qa.fps_sprite; image_speed = 1; alarm[0] = 20;
            break;
        case "partner-moving":
        case "partner-overlap": sprite_index = s_redblock; mask_index = s_redblock; break;
    }
    timing_qa_sample_instance("create-native", id);
}

function timing_qa_actor_step() {
    timingqa_step_count += 1;
    var _age = timingqa_step_count;
    // Changes occur only in genuine native Step bodies, guarded by the same
    // production policy as gameplay actors. No position is manually updated.
    switch (timingqa_role) {
        case "signed-negative":
            if (_age == 12) { direction = 210; speed = -2.75; }
            if (_age == 24) { direction = 270; speed = -1.25; friction = 0; }
            if (_age == 36) { speed = 0; direction = 137; gravity = 0; }
            if (_age == 42) { direction = 137; speed = -2; gravity = 0.125; }
            break;
        case "zero-direction":
            if (_age == 8) { direction = 123; speed = -2; }
            if (_age == 20) { speed = 0; direction = 271; }
            if (_age == 32) { direction = 271; speed = -1.5; }
            break;
        case "diagonal":
            if (_age == 18) { direction = 225; speed = 2.5; image_xscale = -1; }
            break;
        case "native-path":
            if (_age == 16) path_speed = -2;
            if (_age == 32) path_speed = 2;
            break;
        case "collision-moving":
            if (_age == 30) { direction = 180; speed = 2; }
            if (_age == 60) speed = 0;
            break;
        case "animation-fps-origin":
        case "animation-frame-origin":
            if (_age == 16) image_speed = 0.5;
            if (_age == 32) image_speed = 1.25;
            if (_age == 48) image_speed = 0;
            if (_age == 54) image_speed = 1;
            break;
    }
    timing_qa_event("step", id);
}

function timing_qa_summary() {
    if (!variable_global_exists("timing_qa") || !is_struct(global.timing_qa)) return undefined;
    var _qa = global.timing_qa, _actors = [], _off_tick = [];
    for (var _i = 0; _i < array_length(_qa.owned_instances); ++_i)
        array_push(_actors, timing_qa_instance_state(_qa.owned_instances[_i]));
    for (var _e = 0; _e < array_length(_qa.events); ++_e) {
        if (!_qa.events[_e].isTick) array_push(_off_tick, _qa.events[_e]);
    }
    return {schemaVersion:_qa.schemaVersion, fixture:_qa.fixture, verdict:"unassessed",
        spec:_qa.spec, room:_qa.nativeRoom, startTick:_qa.start_tick, startRender:_qa.start_render,
        targetTicks:_qa.target_ticks, observedThroughTick:_qa.observed_through_tick,
        observationWindowComplete:_qa.observed_through_tick - _qa.start_tick >= _qa.target_ticks,
        outerFramesObserved:_qa.outer_sequence, logicalOuterFrames:_qa.tick_outer_count,
        skippedOuterFrames:_qa.skipped_outer_count, renderCap:_qa.setup_render_cap,
        gameplayHz:_qa.setup_gameplay_hz, nativeOuterHz:_qa.setup_native_outer_hz,
        duplicateBeginHooks:_qa.outer_hook_duplicate_count, duplicateEndHooks:_qa.after_hook_duplicate_count,
        endHooksWithoutBegin:_qa.after_hook_missing_begin_count, outerLimitReached:_qa.outer_limit_reached,
        samplesTruncated:_qa.samples_truncated, eventsTruncated:_qa.events_truncated,
        droppedSamples:_qa.dropped_samples, droppedEvents:_qa.dropped_events,
        lateCreationPending:_qa.late_pending, lateCreatedOnSkippedFrame:_qa.late_created_on_skip,
        lateCreationTick:_qa.late_creation_tick, animations:_qa.animations,
        postFlushHookCounts:_qa.post_flush_hook_counts, duplicatePostFlushHooks:_qa.post_flush_duplicates,
        noStepLifecycleStage:_qa.nostep_stage, noStepReactivatedOnSkippedFrame:_qa.nostep_reactivated_on_skip,
        noStepPresent:instance_exists(_qa.nostep_instance), noStepDestroyed:_qa.nostep_destroyed,
        inactiveReadFailures:_qa.inactive_read_errors, lifecycleActions:_qa.lifecycle_actions,
        nativeCallbackEntries:_qa.native_entries, cleanupPending:_qa.cleanup_pending,
        nativeLayers:{verdict:"unassessed", definitions:_qa.owned_layers,
            samples:_qa.layer_samples, samplesTruncated:_qa.layer_samples_truncated},
        actors:_actors, samples:_qa.samples, events:_qa.events, eventBodiesOnSkippedFrames:_off_tick,
        limits:["isolated empty room required", "native acceptance needs cross-rate comparison to the 60 Hz baseline",
            "instance Begin/End order is supplementary; named flush hooks do not assert final instance Step order",
            "same-room restart is not exercised; requires the separate real-campaign native check",
            "requested rendering cap does not assert delivered display FPS"]};
}
