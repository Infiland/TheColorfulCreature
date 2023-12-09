if global.LEBuild = 1 {
instance_destroy()
instance_create(x,y,o_playerdead)
audio_play_sound(snd_dead,5,0)
}