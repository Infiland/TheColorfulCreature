audio_play_sound(snd_shooter,10,0)
if !instance_place(x,y,o_ammo) {
instance_create(x,y,o_ammo)
}
instance_destroy() 