function scr_loadandroid() {
	var directory = working_directory + "/Save Files/"
	if (file_exists(directory + "Android.sav")) {
	ini_open(directory + "Android.sav")
	
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
	
	global.androidleftx = ini_read_real("Android","Left X",leftx);
	global.androidlefty = ini_read_real("Android","Left Y",lefty);
	global.androidrightx = ini_read_real("Android","Right X",rightx);
	global.androidrighty = ini_read_real("Android","Right Y",righty);
	global.androidjumpx = ini_read_real("Android","Jump X",jumpx);
	global.androidjumpy = ini_read_real("Android","Jump Y",jumpy);
	global.androidinteractx = ini_read_real("Android","Interact X",interactx);
	global.androidinteracty = ini_read_real("Android","Interact Y",interacty);
	global.androidskipx = ini_read_real("Android","Skip X",skipx);
	global.androidskipy = ini_read_real("Android","Skip Y",skipy);
	global.androidrestartx = ini_read_real("Android","Restart X",restartx);
	global.androidrestarty = ini_read_real("Android","Restart Y",restarty);
	}
	else {
	}
}