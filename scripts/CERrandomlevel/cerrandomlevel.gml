function CERrandomlevel() {
    // Pick from enabled groups directly. The old rejection recursion never
    // terminated for an empty configuration and repeatedly resampled zeros.
    var _enabled = [];
    for (var _i = 1; _i <= 26; ++_i) {
        var _name = "CERL" + string(_i);
        if (variable_global_exists(_name) && variable_global_get(_name) != 0) array_push(_enabled, _i);
    }
    if (array_length(_enabled) == 0) return false;
    global.chooserandomlevel = _enabled[irandom(array_length(_enabled) - 1)];
    return true;
}
