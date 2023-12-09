if room = r_leveleditor {
if global.LEMode = 1 {
timer = originaltimer
}
}
if global.pause = 1 { exit }
timer -= 1 * (60 / global.maxfps)
if timer < 0 {
if instance_exists(o_player) {
if global.pause = 0 {
instance_create(x+16,y+20,o_rocket)
if distance_to_object(o_player) < 500 {
if !audio_is_playing(snd_rocket) {
audio_play_sound(snd_rocket,0,0)
}
}
}

timer = originaltimer

}}