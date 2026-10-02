if (settings_fps_input_blocked() || global.choosesettings != 3) exit;
if (!platform_touch() || gamepad_remap_active_device() >= 0) {
    var _names = settings_keyboard_names(), _defaults = settings_keyboard_defaults();
    for (var _i = 0; _i < 6; ++_i) variable_global_set(_names[_i], _defaults[_i]);
    gamepad_remap_defaults();
    if (instance_exists(o_settingspausemenu)) { global.isreversed = true; scr_saveachievements(); }
}
if (platform_touch()) { platform_touch_defaults(); scr_saveandroid(); }
scr_savesettings();
