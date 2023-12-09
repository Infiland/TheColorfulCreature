if global.pianohealth = 0 {
if place_meeting(x,y,o_spiketopboss3) {
instance_create(x,y,o_explosion)
instance_create(832,640,o_door)
audio_play_sound(snd_explosionboss,0,0)
audio_stop_sound(m_pianotime)
global.boss3 = 1
global.world1 = 1
global.world2 = 1
global.world3 = 1
scr_savegame()
scr_saveskins()
scr_checkachievements()
instance_destroy()
}}