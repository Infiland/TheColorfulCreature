centerx = camera_get_view_x(view_camera[0]) + 512
propery = camera_get_view_y(view_camera[0])

if keyboard_check_released(vk_escape) {
instance_destroy()	
}

if sizewidth < 100 {
if !keyboard_check(vk_control) {
if keyboard_check(vk_right) {
sizewidth += 1	
}} else {
if keyboard_check_pressed(vk_right) {
	sizewidth += 1
}}}

if sizewidth > 32 {
if !keyboard_check(vk_control) {
if keyboard_check(vk_left) {
sizewidth -= 1	
}} else {
if keyboard_check_pressed(vk_left) {
	sizewidth -= 1
}}}

if  sizeheight > 22 {
if !keyboard_check(vk_control) {
if keyboard_check(vk_down) {
 sizeheight -= 1	
}} else {
if keyboard_check_pressed(vk_down) {
	 sizeheight -= 1
}}}

if  sizeheight < 100 {
if !keyboard_check(vk_control) {
if keyboard_check(vk_up) {
 sizeheight += 1	
}} else {
if keyboard_check_pressed(vk_up) {
	 sizeheight += 1
}}}


if keyboard_check_pressed(vk_enter) {
if global.levelname != "" {
global.LELevelWidthBlocks = sizewidth
global.LELevelHeightBlocks = sizeheight
room_set_width(r_leveleditor,32*sizewidth)
room_set_height(r_leveleditor,64+(32*sizeheight))
scr_saveleveleditor()

var directory = game_save_id + "/LevelEditor Files/" + "/" + global.levelname + "/"
	if (file_exists(directory + "OtherLevelEditor.sav")) {
	ini_open(directory + "OtherLevelEditor.sav");
	global.LELevelWidthBlocks = ini_read_real("Other LE","Level Width Blocks",32);
	global.LELevelHeightBlocks = ini_read_real("Other LE","Level Height Blocks",22);
	ini_close();
	}
	
	room_set_height(r_leveleditor,64+ (32*global.LELevelHeightBlocks))
	room_set_width(r_leveleditor,32*global.LELevelWidthBlocks)

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