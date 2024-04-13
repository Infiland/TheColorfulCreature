rotate = 0
bosshit1 = 1
repeat (irandom_range(3,7)) { var star = instance_create(x+16,y+16,o_itemstar);
with star { image_blend = c_yellow }
}
audio_play_sound(snd_hitboss,5,0)
audio_stop_sound(m_hotdogtimephase1)
audio_stop_sound(m_hotdogtimephase2)
hp -= 1
if hp = 0 {
instance_create(x,y,o_explosion)
instance_destroy()
global.boss1 = 1
scr_savegame()
scr_checkachievements()
o_narrator.l = 0
audio_play_sound(snd_explosionboss,0,0)
global.world1 = 1
global.skin[3] = 1
scr_saveskins()
audio_stop_sound(m_hotdogtimephase3)
}
littlepause = 1
alarm[1] = 50 * (global.maxfps / 60) 