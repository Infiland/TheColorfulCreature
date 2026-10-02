if (!timing_is_tick()) exit;
if global.LEBuild = 1 {
audio_play_sound(snd_shooter,0,0)
instance_destroy();
}