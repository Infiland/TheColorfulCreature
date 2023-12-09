audio_stop_all()
instance_destroy(o_fpscounter)
instance_destroy(o_fullscreensystem)

if global.hardmodeunlock <= 1 {
audio_play_sound(snd_notenough,10,0)
} else {
instance_create(x,y,o_endingslides)	
}