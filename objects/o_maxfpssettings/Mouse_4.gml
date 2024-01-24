//exit
if global.choosesettings != 0 { exit }

if image_alpha != 0.5 {

image_index += 1
if image_index > 5 { image_index = 0}
switch(image_index) {
case(0): global.maxfps = 60 break;
case(1): global.maxfps = 75 break;
case(2): global.maxfps = 100 break;
case(3): global.maxfps = 120 break;
case(4): global.maxfps = 144 break;
case(5): global.maxfps = 150 break;
}
	game_set_speed(global.maxfps, gamespeed_fps);
	room_speed = global.maxfps
}