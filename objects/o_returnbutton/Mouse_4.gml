/// @description Click to go back
if (settings_fps_input_blocked()) exit;
if instance_exists(o_namelevelLE) { exit }
scr_savesettings()

scr_back()
// Keep practice eligibility while returning from pause/settings.
window_set_cursor(cr_default)
