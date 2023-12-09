randomize()
image_xscale = 2
image_yscale = 2
speed = 1 * (60 / global.maxfps) 
if global.easy = 1 {
speed = -1 * (60 / global.maxfps) 
}
image_angle = random_range(0,360);
if instance_exists(o_player) {	
action_move_point(o_player.x,o_player.y,speed);
audio_play_sound(snd_shooter,5,0)
audio_play_sound(snd_shooter,5,0)
audio_play_sound(snd_shooter,5,0)
audio_play_sound(snd_shooter,5,0)
audio_play_sound(snd_shooter,5,0)
audio_play_sound(snd_shooter,5,0)
}
timer = 90