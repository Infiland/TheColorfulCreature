scr_playercontrolsconfig()

if (platform_mobile()) {
key_left = instance_exists(o_buttonleftandroid) && o_buttonleftandroid.pressed;
key_right = instance_exists(o_buttonrightandroid) && o_buttonrightandroid.pressed;
} else {
if leftcontrols = 0 {
key_left = (tcc_gamepad_axis_value(0,gp_axislh) < -0.2 || tcc_gamepad_button_check(0,gp_padl)) || keyboard_check(ord(global.controlsmoveleft))
}
if leftcontrols = 1 {
key_left = (tcc_gamepad_axis_value(0,gp_axislh) < -0.2 || tcc_gamepad_button_check(0,gp_padl)) || keyboard_check(global.controlsmoveleft)
}
//Right
if rightcontrols = 0 {
key_right = (tcc_gamepad_axis_value(0,gp_axislh) > 0.2 || tcc_gamepad_button_check(0,gp_padr)) || keyboard_check(ord(global.controlsmoveright));
}
if rightcontrols = 1 {
key_right = (tcc_gamepad_axis_value(0,gp_axislh) > 0.2 || tcc_gamepad_button_check(0,gp_padr)) || keyboard_check(global.controlsmoveright);
}
}

if global.pause = 1{ exit }
image_index = 0
if key_right { image_index = 1 }
if key_left { image_index = 2 }
if key_left and key_right { image_index = 3 }

y = lerp(y,544,0.03* (60 / global.maxfps))
