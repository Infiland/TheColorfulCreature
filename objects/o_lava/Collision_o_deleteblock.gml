if (!timing_is_tick()) exit;
if global.LEBuild = 3 {
instance_destroy()
audio_play_sound(snd_shooter,10,0)
}