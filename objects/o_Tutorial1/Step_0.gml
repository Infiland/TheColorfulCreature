if (!timing_instance_step()) exit;
scr_playercontrolsconfig()

if (platform_mobile()) {
key_left = instance_exists(o_buttonleftandroid) && o_buttonleftandroid.pressed;
key_right = instance_exists(o_buttonrightandroid) && o_buttonrightandroid.pressed;
} else {
if leftcontrols = 0 {
key_left = timing_keyboard_down(ord(global.controlsmoveleft))
}
if leftcontrols = 1 {
key_left = timing_keyboard_down(global.controlsmoveleft)
}
//Right
if rightcontrols = 0 {
key_right = timing_keyboard_down(ord(global.controlsmoveright));
}
if rightcontrols = 1 {
key_right = timing_keyboard_down(global.controlsmoveright);
}
}

// Controller indicators merge with touch or keyboard on every platform.
var _tutorial_axis = gamepad_ui_axis(gp_axislh);
key_left = key_left || _tutorial_axis < -0.2 || gamepad_ui_down(gamepad_remap_get(1));
key_right = key_right || _tutorial_axis > 0.2 || gamepad_ui_down(gamepad_remap_get(0));

if global.pause = 1{ exit }
image_index = 0
if key_right { image_index = 1 }
if key_left { image_index = 2 }
if key_left and key_right { image_index = 3 }

y = lerp(y,544,0.03* (60 / global.maxfps))
