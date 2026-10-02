if (!timing_instance_step()) exit;
/// @description Keys presses



if global.naminglevel = true {
if(timing_keyboard_down(vk_anykey) and string_length(text) < 40) {
text += string(keyboard_string)
keyboard_string = "";
}
if timing_keyboard_pressed(vk_backspace) {
text = string_delete(text,string_length(text),1)
keyboard_string = "";
delete_timer = -4 * floor((global.maxfps / 60))
}
//Handle Delete time
if delete_timer != 2 {
delete_timer += 1;
}
if timing_keyboard_pressed(vk_enter) {
    if (level_editor_open(text)) instance_destroy();
}

if timing_keyboard_released(vk_escape) {
instance_destroy()
global.levelname = global.previoustext
global.naminglevel = false
}
}
