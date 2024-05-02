//Fullscreen shortcut
game_set_speed(global.maxfps, gamespeed_fps);
room_speed = global.maxfps

if global.fullscreen = 0 { global.fullscreen = 1
	window_enable_borderless_fullscreen(true);
	window_set_fullscreen(true);
	} else { global.fullscreen = 0
		window_set_fullscreen(false);
}
scr_savesettings()