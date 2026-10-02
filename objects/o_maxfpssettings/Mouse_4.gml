if (settings_fps_input_blocked() || global.choosesettings != 0) { exit; }
if (image_alpha != 0.5) {
    global.renderfps = settings_fps_next_preset(global.renderfps);
    var _presets = settings_fps_presets();
    image_index = 0;
    for (var _i = 0; _i < array_length(_presets); ++_i) {
        if (global.renderfps == _presets[_i]) image_index = _i;
    }
    settings_fps_apply_rate();
    scr_savesettings();
}
