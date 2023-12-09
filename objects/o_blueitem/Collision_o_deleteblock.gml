if global.LEBuild = 1 {
instance_destroy()
audio_play_sound(snd_pickup,5,0);

instance_create(x+16,y+16,o_bluepickup);
}