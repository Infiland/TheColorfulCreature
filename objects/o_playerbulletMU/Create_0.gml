playerbullet = 1 //Center
playerbullet = 1 //Right
playerbullet = 2  //Left
if distance_to_object(o_onewayleftblock) < 3 { instance_destroy()}
if distance_to_object(o_onewayrightblock) < 3 { instance_destroy()}
audio_play_sound(snd_smallexplosion,0,0)
hp = 1
inwater = 1
depth = 1