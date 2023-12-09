if global.level100trap = 0 {
if instance_place(x,y,o_player) {
global.level100trap = 1
audio_stop_sound(m_thecastle)
audio_play_sound(snd_spaceship,0,0)
audio_play_sound(snd_youfellformytrap,10,0)
instance_create(512,320,o_invisibleblock)
instance_create(512,352,o_invisibleblock)
instance_create(512,384,o_invisibleblock)
instance_create(512,416,o_invisibleblock)
instance_create(340,-416,o_enemyplayer)
alarm[0] = 276 * (global.maxfps / 60)
}}