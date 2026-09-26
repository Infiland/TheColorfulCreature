if global.choosesettings != 3 { exit }

if !platform_mobile() {
global.controlsskiplevel = "C"
global.controlsinteract = "X"
global.controlsjump = "Z"
global.controlsmoveright = "39"
global.controlsmoveleft = "37"
global.controlsrestart = "R"
// Reset controller bindings to defaults too
gamepad_remap_defaults()
	if instance_exists(o_settingspausemenu) {
	global.isreversed = true
	scr_saveachievements()
	}

} else {

platform_touch_defaults();
scr_saveandroid();
}
