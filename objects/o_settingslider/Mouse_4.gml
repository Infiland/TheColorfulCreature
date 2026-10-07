if (platform_mobile()) exit; // The full mobile row is hit-tested in Step.
if (settings_fps_input_blocked() || global.choosesettings != slider_menu) exit;
grab = timing_device_mouse_down(0, mb_left);
global.soundchange = slider_soundchange_id;
