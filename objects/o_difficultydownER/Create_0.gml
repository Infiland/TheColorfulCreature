if global.endlessrunmode = 2 { 
	instance_destroy()
	exit}

if !instance_exists(o_smoothcamera) {
x = room_width / 2
} else { x = camera_get_view_border_x(view_camera[0]) + room_width / 2 }

y = camera_get_view_border_y(view_camera[0]) - 800
alarm[0] = 1
depth = -10000
timerdifficultylogo = 0
audio_sound_gain(snd_difficultydownER,global.soundvolume*2,1)
audio_play_sound(snd_difficultydownER,10,0)