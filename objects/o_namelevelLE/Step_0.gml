/// @description Keys presses
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
global.levelname = text
rousr_dissonance_set_details("Making a Level - " + global.levelname)
instance_destroy()
global.naminglevel = false
}

if keyboard_check_released(vk_escape) {
instance_destroy()
global.levelname = global.previoustext
global.naminglevel = false
}
}