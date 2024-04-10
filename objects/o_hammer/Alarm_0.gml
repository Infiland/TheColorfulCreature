if global.boss2health = 5 {
	instance_create(384,608,o_spike)
	instance_create(480,608,o_spike)
	if global.deaths < 100 {
	instance_create(608,448,o_spike)
	}
	instance_create(160,288,o_buttonadvantage2)
	image_index = 1
	}
	if global.boss2health = 4 {
	instance_create(864,608,o_spike)
	if global.deaths < 100 {
	instance_create(736,608,o_spike)
	instance_create(768,448,o_spike)
	}
	instance_create(832,608,o_buttonadvantage2)
	image_index = 2
	}
	if global.boss2health = 3 {
	instance_create(576,608,o_spike)
	instance_create(118,544,o_shooterright)
	instance_create(352,448,o_spike)
	if global.deaths < 100 {
	instance_create(672,288,o_spike)
	}
	instance_create(160,288,o_buttonadvantage2)
	image_index = 3
	}
	if global.boss2health = 2 {
	instance_create(842,384,o_shooter)
	if global.deaths < 100 {
	instance_create(512,448,o_spike)
	instance_create(288,608,o_spike)
	}
	instance_create(832,608,o_buttonadvantage2)
	image_index = 4
	}
	if global.boss2health = 1 {
	instance_create(86,512,o_spike)
	if global.deaths < 100 {
	instance_create(416,448,o_spike)
	instance_create(288,288,o_spike)
	}
	instance_create(160,288,o_buttonadvantage2)
	image_index = 5
	}
	
	if global.boss2health = 0 {
		global.boss2 = 1
		audio_play_sound(snd_explosionboss,0,0)
		audio_stop_sound(m_hammertime);
	instance_destroy(o_spike)	
	instance_destroy(o_shooterright)
	instance_destroy(o_shooter)	
	instance_destroy();
	instance_create(x,y-60,o_explosion)
	instance_create(832,576,o_door)
	global.world1 = 1
	global.world2 = 1
	global.skin[6] = 1
	scr_saveskins()
	scr_savegame()
	scr_checkachievements()
	}