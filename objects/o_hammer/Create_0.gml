if global.berserk = 1 {
	global.boss2 = 1
	audio_play_sound(snd_explosionboss,0,0)
	audio_stop_sound(m_hammertime);
	instance_destroy(o_spike)	
	instance_destroy(o_shooterright)
	instance_destroy(o_shooter)	
	instance_destroy();
	instance_create(x,y-60,o_explosion)
	instance_create(832,576,o_door)	
}

global.boss2button = 0
global.boss2health = 6;
image_xscale = 0.25
image_yscale = 0.25
image_index = 0
image_speed = 0
rotate = 0
if !audio_is_playing(m_hammertime) {
	audio_play_sound(m_hammertime,0,1);	
	if global.boss2 = 1 {
	audio_stop_all()
}}
if global.boss2 = 1 {
instance_destroy()
}
animation2 = 0.25
change2 = 0