if room = r_leveleditor {
if global.LEMode = 1 {
timer = originaltimer
}
}

if timer < 0 {
instance_create(x+16,y+16,o_bulletright)
if distance_to_object(o_player) < 1024 {
audio_play_sound(snd_shooter,5,0)
}
image_speed = 1
timer = originaltimer
}
if global.pause = 0 { timer -= 1* (60 / global.maxfps) }