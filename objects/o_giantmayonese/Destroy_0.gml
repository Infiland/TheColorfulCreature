randomangle = random_range(0,360)
audio_play_sound(snd_spaceship,0,0)
var spawn
spawn = instance_create(x,y,o_mayonese)
spawn.image_angle = 0 + randomangle
spawn = instance_create(x,y,o_mayonese)
spawn.image_angle = 60 + randomangle
spawn = instance_create(x,y,o_mayonese)
spawn.image_angle = 120 + randomangle
spawn = instance_create(x,y,o_mayonese)
spawn.image_angle = 180 + randomangle
spawn = instance_create(x,y,o_mayonese)
spawn.image_angle = 240 + randomangle
spawn = instance_create(x,y,o_mayonese)
spawn.image_angle = 300 + randomangle
with o_mayonese {
direction = image_angle
speed = 3
}