randomize()
originalspeed = random_range(4* (60 / global.maxfps) ,6* (60 / global.maxfps) )
if global.easy = 1 {
speed = -1	
}

image_angle = random_range(0,360);
if instance_exists(o_player) {	
action_move_point(o_player.x,o_player.y,speed);
audio_play_sound(snd_shooter,5,0)
audio_play_sound(snd_shooter,5,0)
audio_play_sound(snd_shooter,5,0)
}

if global.hardmode = 0 {
sprite_collision_mask(s_ketchup, false, 0, 0, 0, 0, 0, bboxkind_rectangular, 0);
}