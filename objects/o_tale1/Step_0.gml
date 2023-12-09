timer += 1

if timer = 20 {
instance_create(x,y,o_tale2)	
}
if timer = 200 {
instance_create(x,y,o_tale3)
}
if timer = 380 {
instance_create(x,y,o_tale4)
}
if timer = 405 {
instance_create(x,y,o_tale5)
}
if timer = 505 {
instance_create(x,y,o_tale6)
}
if timer = 665 {
instance_create(x,y,o_tale7)
}
if timer = 765 {
instance_destroy(o_tale7)
}
if timer = 830 {
instance_create(random_range(0,room_width),random_range(0,525),o_flickeringstar)
}
if timer = 845 {
instance_create(random_range(0,room_width),random_range(0,525),o_flickeringstar)
}
if timer = 855 {
instance_create(random_range(0,room_width),random_range(0,525),o_flickeringstar)
}
if timer = 865 {
instance_create(random_range(0,room_width),random_range(0,525),o_flickeringstar)
}
if timer = 870 {
instance_create(random_range(0,room_width),random_range(0,525),o_flickeringstar)
}
if timer = 880 {
instance_create(random_range(0,room_width),random_range(0,525),o_flickeringstar)
}
if timer = 895 {
instance_create(random_range(0,room_width),random_range(0,525),o_flickeringstar)
}
if timer = 905 {
instance_create(random_range(0,room_width),random_range(0,525),o_flickeringstar)
}
if timer = 915 {
instance_create(random_range(0,room_width),random_range(0,525),o_flickeringstar)
}
if timer = 920 {
instance_create(random_range(0,room_width),random_range(0,525),o_flickeringstar)
}
if timer = 935 {
instance_create(x,y,o_tale8)
}
if timer = 960 {
instance_create(x,y,o_tale9)
}
if timer = 1130 {
instance_create(x,y,o_tale10)
}
if timer = 1320 {
instance_create(x,y,o_tale11)
}
if timer = 1550 {
instance_create(x,y,o_tale12)
}
if timer = 1750 {
instance_create(x,y,o_tale13)
}
if timer = 1950 {
instance_create(x,y,o_tale14)
}
if timer = 2100 {
instance_create(x,y,o_tale15)
}
if timer = 2250 {
instance_create(x,y,o_tale16)
}
if timer = 2450 {
instance_create(x,y,o_tale17)
}
if timer = 2570 {
instance_create(x,y,o_tale18)
}
if timer = 2670 {
instance_create(x,y,o_tale18)
}
if timer = 2750 {
instance_create(x,y,o_tale19)
}
if timer = 2980 {
instance_create(x,y,o_tale20)
}
if timer = 3220 {
instance_create(x,y,o_tale21)
}
if timer = 3400 {
room_goto(r_taleroom)
	game_set_speed(global.maxfps, gamespeed_fps);
	room_speed = global.maxfps

}

if keyboard_check_pressed(ord("S")) {
audio_stop_sound(m_tale)
room_goto(r_taleroom)
	game_set_speed(global.maxfps, gamespeed_fps);
	room_speed = global.maxfps
}