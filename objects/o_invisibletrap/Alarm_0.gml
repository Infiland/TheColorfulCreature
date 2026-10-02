if (!timing_is_tick()) exit;
instance_create(165,355,o_explosion)
instance_create(285,385,o_explosion)
instance_create(420,370,o_explosion)
audio_play_sound(snd_explosionboss,0,0)
alarm[1] = 40 * (TCC_SIM_HZ / 60)