if (!timing_instance_step()) exit;
centerx = camera_get_view_x(view_camera[0]) + 512
propery = camera_get_view_y(view_camera[0])

if timing_keyboard_released(vk_escape) {
instance_destroy()	
}

if sizewidth < 100 {
if !timing_keyboard_down(vk_control) {
if timing_keyboard_down(vk_right) {
sizewidth += 1	
}} else {
if timing_keyboard_pressed(vk_right) {
	sizewidth += 1
}}}

if sizewidth > 32 {
if !timing_keyboard_down(vk_control) {
if timing_keyboard_down(vk_left) {
sizewidth -= 1	
}} else {
if timing_keyboard_pressed(vk_left) {
	sizewidth -= 1
}}}

if  sizeheight > 22 {
if !timing_keyboard_down(vk_control) {
if timing_keyboard_down(vk_down) {
 sizeheight -= 1	
}} else {
if timing_keyboard_pressed(vk_down) {
	 sizeheight -= 1
}}}

if  sizeheight < 100 {
if !timing_keyboard_down(vk_control) {
if timing_keyboard_down(vk_up) {
 sizeheight += 1	
}} else {
if timing_keyboard_pressed(vk_up) {
	 sizeheight += 1
}}}


if timing_keyboard_pressed(vk_enter) {
if global.levelname != "" {
global.LELevelWidthBlocks = sizewidth
global.LELevelHeightBlocks = sizeheight
room_set_width(r_leveleditor,32*sizewidth)
room_set_height(r_leveleditor,64+(32*sizeheight))
if (!scr_saveleveleditor()) exit;


room_restart()
global.LEMode = 1
instance_create(x,y,o_levelreloadagain)
} else {
pressedenter = 0.5
}
}

if pressedenter > 0 {
	pressedenter = lerp(pressedenter,0,0.1 * (60 / global.maxfps))
} else {
pressedenter = 0	
}