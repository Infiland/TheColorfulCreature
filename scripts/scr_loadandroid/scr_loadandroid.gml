function scr_loadandroid() {
    platform_touch_defaults();
    var _path = directory_set("/Save Files/") + "Android.sav";
    scr_save_recover(_path);
    if (!file_exists(_path)) return;
    ini_open(_path);
    var _layout = ini_read_real("Android", "Layout", 1);
    global.androidbuttonsize = floor(platform_touch_clamp(ini_read_real("Android", "Button Size", 0), 0, 2, 0));
    // Layout 3 moved the controls beside the playfield; older positions would cover it.
    if (_layout >= 3) {
        var _names = ["left", "right", "jump", "interact", "skip", "restart"];
        var _keys = ["Left", "Right", "Jump", "Interact", "Skip", "Restart"];
        for (var _i = 0; _i < array_length(_names); ++_i) {
            var _xvar = "android" + _names[_i] + "x";
            var _yvar = "android" + _names[_i] + "y";
            var _x = ini_read_real("Android", _keys[_i] + " X", variable_global_get(_xvar));
            var _y = ini_read_real("Android", _keys[_i] + " Y", variable_global_get(_yvar));
            if (is_real(_x) && !is_nan(_x) && !is_infinity(_x) && abs(_x) <= 8192) variable_global_set(_xvar, _x);
            if (is_real(_y) && !is_nan(_y) && !is_infinity(_y) && abs(_y) <= 8192) variable_global_set(_yvar, _y);
        }
    }
    ini_close();
    if (_layout < 3) platform_touch_place_defaults();
}
