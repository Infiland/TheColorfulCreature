function selecthatCUSTOM(i,text){
if mouse_check_button_pressed(mb_left) {
if mouse_x > room_width/2-300 && mouse_x < room_width/2+300 && mouse_y > 85+i*40 && mouse_y < 115+i*40 {
global.CUSTOMhat = text
show_debug_message(text)
scr_savehats()
}}}