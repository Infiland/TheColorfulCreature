if (!timing_instance_step()) exit;
scr_playercontrolsconfig()
if (platform_mobile()) {
key_jump = instance_exists(o_buttonjumpandroid) && o_buttonjumpandroid.pressed;
} else {
if jumpcontrols = 0 { key_jump = timing_keyboard_down(ord(global.controlsjump)) }
else { key_jump = timing_keyboard_down(global.controlsjump) }
}
// Controller indicators merge with touch or keyboard on every platform.
key_jump = key_jump || gamepad_ui_down(gamepad_remap_get(2));
if global.pause = 1{ exit }
image_index = 0
if key_jump { image_index = 1 }
y = lerp(y,32,0.03* (60 / global.maxfps))
