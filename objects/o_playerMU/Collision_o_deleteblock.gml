if global.LEBuild = 1 {
instance_destroy()
instance_create(x,y,o_playerdead)
if global.sound = 1 { audio_play_sound(snd_dead,5,0) }
}