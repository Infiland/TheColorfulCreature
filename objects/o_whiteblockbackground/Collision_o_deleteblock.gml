if (!timing_is_tick()) exit;
if global.LEBuild = 2 {
instance_destroy()
audio_play_sound(snd_shooter,10,0)
}