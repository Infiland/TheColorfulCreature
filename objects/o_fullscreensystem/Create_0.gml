global.windowsresizemain = application_get_position();
global.pause = 0
xx = global.windowsresizemain[0];
yy = global.windowsresizemain[1];
ww = global.windowsresizemain[2] - global.windowsresizemain[0];
hh = global.windowsresizemain[3] - global.windowsresizemain[1];

mConX = window_get_width() / 2
mConY = window_get_height() / 2

controllermode = 0
ingame = 0

alarm[0] = 10