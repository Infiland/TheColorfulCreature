if room = r_support {
	if !steam_get_achievement("CLICK_THE_HOTDOG") {
	steam_set_achievement("CLICK_THE_HOTDOG") }
image_speed = 1
repeat (irandom_range(3,7)) { var star = instance_create(x+16,y+16,o_itemstar);
with star { image_blend = c_yellow }}
audio_play_sound(snd_hitboss,5,0)
rotate = 0
bosshit1 = 1
}