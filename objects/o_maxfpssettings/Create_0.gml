var _presets = settings_fps_presets();
image_index = 0;
for (var _i = 0; _i < array_length(_presets); ++_i) {
    if (global.renderfps == _presets[_i]) image_index = _i;
}
depth = -1000000000;
