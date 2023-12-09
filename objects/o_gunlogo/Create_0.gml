if !instance_exists(o_smoothcamera) {
x = room_width + 200
y = room_height / 2
}
if instance_exists(o_smoothcamera) {
x = o_smoothcamera.x + 200
y = o_smoothcamera.y
}
depth = -10000
timergunlogo = 0
audio_sound_gain(snd_gunvoice,global.soundvolume,1)
audio_play_sound(snd_gunvoice,10,0)