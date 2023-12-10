/// @description Keys presses
var directory = game_save_id + "/LevelEditor Files/" + "/" + text + "/"


if global.naminglevel = true {
if(keyboard_check(vk_anykey) and string_length(text) < 40) {
text += string(keyboard_string)
keyboard_string = "";
}
if keyboard_check_pressed(vk_backspace) {
text = string_delete(text,string_length(text),1)
keyboard_string = "";
delete_timer = -4 * floor((global.maxfps / 60))
}
//Handle Delete time
if delete_timer != 2 {
delete_timer += 1;
}
if keyboard_check_pressed(vk_enter) {
instance_destroy()
instance_destroy(o_allbackgrounds)
global.levelname = text
//Load
if global.levelname != "" {

instance_create(x,y,o_levelreloadagain)
if !steam_get_achievement("LOAD_LEVEL") { //Load Level
steam_set_achievement("LOAD_LEVEL") }
} else {
	instance_destroy(o_savedandloaded)
	box = instance_create(x,y,o_savedandloaded)
	with(box) {
	image_index = 3	
	}

}}

if keyboard_check_released(vk_escape) {
instance_destroy()
global.levelname = global.previoustext
global.naminglevel = false
}
}