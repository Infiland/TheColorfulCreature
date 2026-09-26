function scr_loadandroid() {
    platform_touch_defaults();
    var _left_default = global.androidleftx;
    var _right_default = global.androidrightx;
    var _bottom_default = global.androidlefty;
    var _path = directory_set("/Save Files/") + "Android.sav";
    scr_save_recover(_path);
    if (!file_exists(_path)) return;
    ini_open(_path);
    var _layout = ini_read_real("Android", "Layout", 1);
    global.androidbuttonsize = floor(platform_touch_clamp(ini_read_real("Android", "Button Size", 0), 0, 2, 0));
    var _names = ["left", "right", "jump", "interact", "skip", "restart"];
    var _keys = ["Left", "Right", "Jump", "Interact", "Skip", "Restart"];
    for (var _i = 0; _i < array_length(_names); ++_i) {
        var _xvar = "android" + _names[_i] + "x";
        var _yvar = "android" + _names[_i] + "y";
        var _x = ini_read_real("Android", _keys[_i] + " X", variable_global_get(_xvar));
        var _y = ini_read_real("Android", _keys[_i] + " Y", variable_global_get(_yvar));
        // Old saves could contain camera/world coordinates; keep usable custom positions.
        if (is_real(_x) && !is_nan(_x) && !is_infinity(_x) && (_layout >= 2 ? abs(_x) <= 8192 : (_x >= 64 && _x <= 960)))
            variable_global_set(_xvar, _x);
        if (is_real(_y) && !is_nan(_y) && !is_infinity(_y) && (_layout >= 2 ? abs(_y) <= 8192 : (_y >= 64 && _y <= 704)))
            variable_global_set(_yvar, _y);
    }
    ini_close();
    // Repair overlapping legacy movement controls without discarding other custom positions.
    if (_layout < 2 && abs(global.androidleftx - global.androidrightx) < 140 && abs(global.androidlefty - global.androidrighty) < 140) {
        global.androidleftx = _left_default; global.androidrightx = _right_default;
        global.androidlefty = _bottom_default; global.androidrighty = _bottom_default;
    }
}
