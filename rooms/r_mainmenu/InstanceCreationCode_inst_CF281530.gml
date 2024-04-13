audio_sound_gain(m_mainmenu,global.musicvolume,100)
audio_sound_gain(m_credits,0,1)
audio_stop_sound(m_credits)
global.endless = 0
global.workshop = 0
global.challenges = 0

instance_create(930,352,o_profilepicture)



game_set_speed(global.maxfps, gamespeed_fps);
room_speed = global.maxfps