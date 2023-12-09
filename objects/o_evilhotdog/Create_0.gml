if global.berserk = 1 {
audio_stop_all()
instance_create(x,y,o_explosion)
instance_destroy()
global.boss1 = 1
audio_stop_sound(m_hotdogtimephase1)
}

global.boss1finalattack = 0
image_speed = 0
image_angle = -30
animation = -0.5
rotate = 0
bosshit1 = 0
direction_animation = 0
//alarm[0] = 100
timer = 100
hp = 3
littlepause = 0
randomketchup = 0
if global.boss1 = 1 {
instance_destroy()
}

if global.nostalgia = 1 { sprite_index = s_oldhotdog }