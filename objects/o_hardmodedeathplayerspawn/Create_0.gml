audio_stop_all()

if !instance_exists(o_playerdead) {
instance_create(global.gameoverplayerX,global.gameoverplayerY,o_playerdead)
}

audio_play_sound(snd_dead,100,0)
hidehud()
alarm[0] = 1.2 * room_speed
image_speed = 0.8 * (60 / global.maxfps)