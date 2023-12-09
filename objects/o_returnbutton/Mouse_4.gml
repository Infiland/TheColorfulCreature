/// @description Click to go back
if instance_exists(o_namelevelLE) { exit }
scr_savesettings()

scr_back()
global.levelselect = 0
window_set_cursor(cr_default)