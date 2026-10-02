/// Convert 1-based checkbox flags into a bounded set of available options.
function CER_selected_indices(_flags) {
    var _enabled = [];
    for (var _i = 0; _i < array_length(_flags); ++_i) {
        var _value = _flags[_i];
        if (is_numeric(_value) && !is_nan(_value) && !is_infinity(_value) && _value != 0)
            array_push(_enabled, _i + 1);
    }
    return _enabled;
}

function CER_enabled_indices(_prefix, _count) {
    var _flags = array_create(_count, 0);
    for (var _i = 1; _i <= _count; ++_i) {
        var _name = _prefix + string(_i);
        if (variable_global_exists(_name)) _flags[_i - 1] = variable_global_get(_name);
    }
    return CER_selected_indices(_flags);
}

function CER_pick_enabled(_enabled) {
    var _count = array_length(_enabled);
    if (_count == 0) return -1;
    if (_count == 1) return _enabled[0];
    return _enabled[irandom(_count - 1)];
}

function CER_start_availability() {
    return {
        levels:array_length(CER_enabled_indices("CERL",26)) > 0,
        music:array_length(CER_enabled_indices("CERM",29)) > 0
    };
}

function CERrandommusic() {
    // Empty selections return without recursion or changing the current song.
    // Every enabled song appears once; the old choose() listed song 20 twice.
    var _choice = CER_pick_enabled(CER_enabled_indices("CERM",29));
    if (_choice == -1) return false;
    global.chooserandommusic = _choice;
    return true;
}

/// Pure selection fixtures: no save writes, playback, globals, or RNG advances.
function CER_selection_selfcheck() {
    scr_port_assert(CER_pick_enabled(CER_selected_indices(array_create(29,0))) == -1,
        "custom endless all-off music is a bounded empty selection");
    var _levels = array_create(26,0); _levels[25] = 1;
    var _songs = array_create(29,0); _songs[28] = 1;
    scr_port_assert(CER_pick_enabled(CER_selected_indices(_levels)) == 26,
        "custom endless includes level group 26 without reading group zero");
    scr_port_assert(CER_pick_enabled(CER_selected_indices(_songs)) == 29,
        "custom endless includes song 29 as the only enabled track");
    _songs[28] = 0; _songs[19] = 1;
    var _selected = CER_selected_indices(_songs);
    scr_port_assert(array_length(_selected) == 1 && _selected[0] == 20,
        "custom endless song 20 has no duplicate weighting");
    _selected = CER_selected_indices([undefined,"1",0,1,int64(1)]);
    scr_port_assert(array_length(_selected) == 2 && _selected[0] == 4 && _selected[1] == 5,
        "custom endless rejects absent and malformed flags and accepts native numeric flags");
    show_debug_message("TCC_CER_SELECTION_SELF_CHECK_PASS");
}
