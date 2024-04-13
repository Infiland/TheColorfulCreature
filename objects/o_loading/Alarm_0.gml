//Play Main Menu song
if room = r_loading {
if !audio_is_playing(m_mainmenu) {
audio_play_sound(m_mainmenu,0,1)
}
audio_sound_gain(m_mainmenu,global.musicvolume,100)
}

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

if os_type = os_android { //Load controls for android
scr_loadandroid()
}

room_goto(r_mainmenu)

instance_create(x,-500,o_newsbanner)
//Load Lang
switchlang()
//Load Anticheat
scr_anticheat()