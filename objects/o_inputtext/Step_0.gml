/// @description Keys presses
if global.writingmode = 1 {
if(keyboard_check(vk_anykey) and string_length(text) < 256) {
text += string(keyboard_string)
keyboard_string = "";
}

if keyboard_check(vk_backspace) {
//delete_timer -= 1 * floor(60 / global.maxfps)
delete_timer -= 1 * (144 / global.maxfps)
//delete_timer = 1 + floor(60 / global.maxfps)
}

if delete_timer < 1 {
delete_timer = 10
text = string_delete(text,string_length(text),1)
keyboard_string = "";
}

/*if keyboard_check_pressed(vk_backspace) {
text = string_delete(text,string_length(text),1)
keyboard_string = "";

//delete_timer = -4 * floor((global.maxfps / 60))
}*/


/*//Handle Delete time
if delete_timer != 2 {
delete_timer += 1;
}*/
if keyboard_check_pressed(vk_enter) {
global.writingmode = 0
}
global.leveleditorstring = text
}