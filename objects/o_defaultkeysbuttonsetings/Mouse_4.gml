if global.choosesettings != 3 { exit }

if os_type != os_android {
global.controlsskiplevel = "C"
global.controlsinteract = "X"
global.controlsjump = "Z"
global.controlsmoveright = "39"
global.controlsmoveleft = "37"
global.controlsrestart = "R"
	if instance_exists(o_settingspausemenu) {
	global.isreversed = true
	scr_saveachievements()
	}

} else {
	
//Android Controls
var leftx = (camera_get_view_x(view_camera[0]) + (-(o_fullscreensystem.xx) / 2)) + 64;
var lefty = (camera_get_view_y(view_camera[0]) + 576) + 64
var rightx = ((camera_get_view_x(view_camera[0]) + (-(o_fullscreensystem.xx) / 2)) + 160) + 64;
var righty = (camera_get_view_y(view_camera[0]) + 576) + 64
var jumpx = (camera_get_view_x(view_camera[0]) + 1224 - ((o_fullscreensystem.xx) / 1.5)) + 64;
var jumpy = (camera_get_view_y(view_camera[0]) + 576) + 64
var interactx = (1224 + camera_get_view_x(view_camera[0]) - ((o_fullscreensystem.xx) / 1.5)) + 64;
var interacty = (camera_get_view_y(view_camera[0]) + 376) + 64
var skipx = (1224 + camera_get_view_x(view_camera[0]) - ((o_fullscreensystem.xx) / 1.5)) + 64;
var skipy = (camera_get_view_y(view_camera[0]) + 176) + 64
var restartx = (camera_get_view_x(view_camera[0]) + (-(o_fullscreensystem.xx) / 2)) + 64;
var restarty = (camera_get_view_y(view_camera[0]) + 376) + 64

global.androidleftx = leftx
global.androidlefty = lefty
global.androidrightx = rightx
global.androidrighty = righty
global.androidjumpx = jumpx
global.androidjumpy = jumpy
global.androidinteractx = interactx
global.androidinteracty = interacty
global.androidskipx = skipx
global.androidskipy = skipy
global.androidrestartx = restartx
global.androidrestarty = restarty
}