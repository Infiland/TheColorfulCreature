/// @description Click to start
if steam_get_app_id() = 1749610 {
if !instance_exists(o_demoask) {instance_create(x,y,o_demoask)}
exit;
}

if locked = 0 {
window_set_cursor(cr_default)
global.levelselect = 1
global.special = 0
global.hatmerchantdiscount = 1.3333333333333
global.pickup = 0
room_goto(roomselect)
loadhud()
if !audio_is_playing(levelmusic) {
audio_play_sound(levelmusic,0,1)	
}
}