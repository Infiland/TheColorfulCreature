/// Owned sequence playback uses the fixed gameplay clock.
/// Native sequence engine still evaluates tracks, moves heads and dispatches
/// callbacks. This module changes only public per-element speedScale.
/// Existing owned creation sites must use the wrappers below. Logical intent
/// is separate from native hold=0 and FPS-rate compensation.

function timing_sequence_finite(_value) {
    return is_real(_value) && !is_bool(_value) && !is_nan(_value) && !is_infinity(_value);
}

function timing_sequence_boot() {
    if (!variable_global_exists("tcc_sequence_clock") || !is_struct(global.tcc_sequence_clock))
        global.tcc_sequence_clock = {room_ref:room, generation:-1, room_open:false,
            admission_open:false, begin_outer:-1, birth_serial:0, entries:[], invalid:""};
    var _s = global.tcc_sequence_clock;
    if (_s.room_ref != room) {
        // Old room layers are engine-owned; never inspect reused numeric IDs.
        _s.room_ref = room; _s.generation = -1; _s.room_open = false;
        _s.admission_open = false; _s.begin_outer = -1; _s.entries = [];
    }
    return _s;
}

function timing_sequence_find(_element) {
    var _s = timing_sequence_boot();
    for (var _i = 0; _i < array_length(_s.entries); ++_i)
        if (_s.entries[_i].element == _element) return _s.entries[_i];
    return undefined;
}

function timing_sequence_present(_entry) {
    return _entry.room_ref == room && layer_exists(_entry.layer)
        && layer_sequence_exists(_entry.layer, _entry.element);
}

function timing_sequence_can_advance() {
    if (!variable_global_exists("tcc_timing")) return false;
    var _s = timing_sequence_boot(), _t = global.tcc_timing;
    return _s.room_open && _s.admission_open && _s.generation == _t.room_generation
        && _s.begin_outer == timing_render_id() && !_t.begin_pending && timing_is_tick()
        && (!variable_global_exists("pause") || global.pause == 0);
}

function timing_sequence_apply(_entry) {
    if (_entry.invalid != "" || !timing_sequence_present(_entry)) return false;
    try {
        var _asset = layer_sequence_get_sequence(_entry.element);
        var _type = _asset.playbackSpeedType;
        if (_type != spritespeed_framespersecond && _type != spritespeed_framespergameframe)
            throw "Sequence clock unsupported public playback speed type";
        var _hz = game_get_speed(gamespeed_fps);
        if (!timing_sequence_finite(_hz) || _hz <= 0)
            throw "Sequence clock invalid actual native rate";
        var _native_before = layer_sequence_get_speedscale(_entry.element);
        if (!is_undefined(_entry.last_native) && _native_before != _entry.last_native)
            throw "Sequence clock unwrapped native speedScale mutation";
        var _advance = timing_sequence_can_advance();
        var _factor = _type == spritespeed_framespersecond ? _hz / TCC_SIM_HZ : 1;
        var _want = _advance ? _entry.intent_scale * _factor : 0;
        if (!timing_sequence_finite(_want)) throw "Sequence clock nonfinite native scale";
        // Preserve asset playbackSpeed/type, native paused state, head direction,
        // finished state and callback ownership. Never seek/evaluate manually.
        if (_native_before != _want) layer_sequence_speedscale(_entry.element, _want);
        _entry.last_native = layer_sequence_get_speedscale(_entry.element);
        _entry.actual_hz = _hz; _entry.speed_type = _type;
        _entry.factor = _factor; _entry.held = !_advance;
        _entry.applied_outer = timing_render_id();
        return true;
    } catch (_error) {
        _entry.invalid = is_struct(_error) && variable_struct_exists(_error, "message")
            ? _error.message : string(_error);
        global.tcc_sequence_clock.invalid = _entry.invalid;
        // No speculative playback/recovery or hidden track/head writes. Root
        // diagnostics must reject this error rather than count a normalized run.
        return false;
    }
}

function timing_sequence_register_birth(_element) {
    var _s = timing_sequence_boot();
    // Native create just returned a fresh element. Evict reused IDs without
    // reading any old entry or restoring an old speed onto the new element.
    var _keep = [];
    for (var _i = 0; _i < array_length(_s.entries); ++_i)
        if (_s.entries[_i].element != _element) array_push(_keep, _s.entries[_i]);
    _s.entries = _keep;
    if (array_length(_s.entries) >= 16) throw "Sequence clock exceeds owned element budget";
    var _layer = layer_get_element_layer(_element);
    if (!layer_exists(_layer) || !layer_sequence_exists(_layer, _element))
        throw "Sequence clock native creation returned an absent element";
    var _intent = layer_sequence_get_speedscale(_element);
    if (!timing_sequence_finite(_intent)) throw "Sequence clock invalid initial native scale";
    _s.birth_serial += 1;
    var _entry = {element:_element, layer:_layer, room_ref:room, generation:_s.generation,
        pending_birth:!_s.room_open, birth_serial:_s.birth_serial,
        birth_outer:timing_render_id(), birth_tick:timing_tick_id(),
        intent_scale:_intent, last_native:undefined, actual_hz:undefined,
        factor:undefined, speed_type:undefined, held:true, applied_outer:-1, invalid:""};
    array_push(_s.entries, _entry);
    timing_sequence_apply(_entry);
    return _entry;
}

// Exact native Create -> owned registration/hold -> return -> caller Play order.
// Registration is immediate for sequences: late native head advancement must
// be held on a skipped/partial outer; subsequent caller scale/play use wrappers.
function timing_sequence_create(_layer, _x, _y, _asset) {
    var _element = layer_sequence_create(_layer, _x, _y, _asset);
    timing_sequence_register_birth(_element);
    return _element;
}

function timing_sequence_play(_element) {
    var _entry = timing_sequence_find(_element);
    if (is_undefined(_entry)) throw "Sequence clock play requires owned creation";
    layer_sequence_play(_element);
    timing_sequence_apply(_entry);
}

function timing_sequence_pause(_element) {
    var _entry = timing_sequence_find(_element);
    if (is_undefined(_entry)) throw "Sequence clock pause requires owned creation";
    layer_sequence_pause(_element);
    timing_sequence_apply(_entry);
}

function timing_sequence_speedscale(_element, _scale) {
    if (!timing_sequence_finite(_scale)) throw "Sequence clock invalid logical scale";
    var _entry = timing_sequence_find(_element);
    if (is_undefined(_entry)) throw "Sequence clock scale requires owned creation";
    _entry.intent_scale = _scale;
    timing_sequence_apply(_entry);
}

// Production consumers use this getter for logical intent. The native observer
// intentionally keeps layer_sequence_get_speedscale to read the actual rate.
function timing_sequence_get_speedscale(_element) {
    var _entry = timing_sequence_find(_element);
    if (is_undefined(_entry)) throw "Sequence clock getter requires owned creation";
    return _entry.intent_scale;
}

function timing_sequence_room_end() {
    var _s = timing_sequence_boot();
    _s.admission_open = false; _s.room_open = false; _s.begin_outer = -1;
    _s.entries = [];
    // The real engine owns room element/callback destruction. No stale lookup,
    // forced pause/play, native destroy or callback dispatch occurs here.
}

function timing_sequence_room_start() {
    var _s = timing_sequence_boot(), _t = global.tcc_timing;
    if (_s.room_open && _s.generation == _t.room_generation) return;
    if (_s.room_open && _s.generation != _t.room_generation)
        _s.invalid = "Sequence clock Room End notification missing";
    var _new = [];
    for (var _i = 0; _i < array_length(_s.entries); ++_i) {
        var _entry = _s.entries[_i];
        if (!_entry.pending_birth || !timing_sequence_present(_entry)) continue;
        _entry.generation = _t.room_generation; _entry.pending_birth = false;
        array_push(_new, _entry);
    }
    _s.entries = _new; _s.generation = _t.room_generation; _s.room_open = true;
    _s.admission_open = false; _s.begin_outer = -1;
    timing_sequence_flush();
}

// Root calls after its final late-Begin game_set_speed decision, before native
// sequence advancement and before sequence Begin observations. Read actual Hz.
function timing_sequence_begin() {
    var _s = timing_sequence_boot();
    _s.admission_open = _s.room_open;
    _s.begin_outer = timing_render_id();
    timing_sequence_flush();
}

// Root Step pending flush, and immediate real global.pause change notification.
// No ticking, clock debt, input or QA frame mutation is performed here.
function timing_sequence_flush() {
    var _s = timing_sequence_boot(), _live = [];
    for (var _i = 0; _i < array_length(_s.entries); ++_i) {
        var _entry = _s.entries[_i];
        if (!timing_sequence_present(_entry)) continue;
        timing_sequence_apply(_entry); array_push(_live, _entry);
    }
    _s.entries = _live;
}

// Place after the native sequence evaluation has ended at root End, before
// End observation/Draw. Repeated End calls remain idempotent. Never auto-play.
function timing_sequence_end() {
    var _s = timing_sequence_boot(); _s.admission_open = false;
    timing_sequence_flush();
}

// Read-only diagnostic view of our intent and actual public native state.
function timing_sequence_state(_element) {
    if (!variable_global_exists("tcc_sequence_clock")) return undefined;
    var _s = global.tcc_sequence_clock, _entry = undefined;
    for (var _i = 0; _i < array_length(_s.entries); ++_i)
        if (_s.entries[_i].element == _element) _entry = _s.entries[_i];
    if (is_undefined(_entry)) return {owned:false, clockInvalid:_s.invalid};
    var _out = {owned:true, clockInvalid:_s.invalid, invalid:_entry.invalid,
        roomMatches:_s.room_ref == room, roomOpen:_s.room_open, generation:_s.generation,
        admissionOpen:_s.admission_open, beginOuter:_s.begin_outer,
        layerRef:_entry.layer, elementRef:_entry.element, intentScale:_entry.intent_scale,
        lastNativeScale:_entry.last_native, actualHz:_entry.actual_hz,
        factor:_entry.factor, speedType:_entry.speed_type, held:_entry.held,
        birthSerial:_entry.birth_serial, birthOuter:_entry.birth_outer, birthTick:_entry.birth_tick,
        pendingBirth:_entry.pending_birth, appliedOuter:_entry.applied_outer,
        nativeQueried:false, nativePresent:undefined};
    // Never query old room layers or numeric IDs through a diagnostic getter.
    if (_s.room_ref != room || _entry.room_ref != room) return _out;
    try {
        _out.nativeQueried = true; _out.nativePresent = timing_sequence_present(_entry);
        if (_out.nativePresent) {
            _out.nativeSpeedScale = layer_sequence_get_speedscale(_element);
            _out.nativePaused = layer_sequence_is_paused(_element);
            _out.nativeFinished = layer_sequence_is_finished(_element);
        }
    } catch (_error) {
        _out.readError = is_struct(_error) && variable_struct_exists(_error, "message")
            ? _error.message : string(_error);
    }
    return _out;
}
