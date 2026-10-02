if (settings_fps_input_blocked() || gamepad_remap_input_blocked() || global.choosesettings != 3 || !visible) exit;
gamepad_remap_cancel();
editcontrols = controls;
global.gp_remap_listening = controls;
capture_device = gamepad_remap_active_device(true);
capture_device_generation = timing_pad_generation(capture_device);
global.gp_remap_device = capture_device;
ischanging = true;
capture_armed = false;
keyboard_string = "";

capture_hint = "";
