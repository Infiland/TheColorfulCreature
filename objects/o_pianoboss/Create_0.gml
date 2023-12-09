randomize();
global.boss3spikespeed = 0.1
if !audio_is_playing(m_pianotime) {
audio_play_sound(m_pianotime,0,1)
}

if global.berserk = 1 {
instance_create(x,y,o_explosion)
instance_create(832,640,o_door)
audio_play_sound(snd_explosionboss,0,0)
audio_stop_sound(m_pianotime)
global.boss3 = 1
instance_destroy(o_spiketopboss3)
}

global.pianobutton1 = irandom_range(1,6)
global.pianobutton2 = irandom_range(1,6)
global.pianobutton3 = irandom_range(1,6)
global.pianobutton4 = irandom_range(1,6)
global.pianobutton5 = irandom_range(1,6)
global.pianobutton6 = irandom_range(1,6)
global.pianobuttonconfirm1 = 0
global.pianobuttonconfirm2 = 0
global.pianobuttonconfirm3 = 0
global.pianobuttonconfirm4 = 0
global.pianobuttonconfirm5 = 0
global.pianobuttonconfirm6 = 0
global.pianotries = 1
global.pianohealth = 3
alarm[0] = 30