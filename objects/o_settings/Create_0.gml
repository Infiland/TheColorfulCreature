image_index = global.foundcog
depth = -15000
rotate = 0
pitch = 1
move = 0

vx = 0
vy = 0

if room = r_mainmenu {
vy = -64	
}

if instance_exists(o_smoothcamera) {
vx = camera_get_view_x(view_camera[0])
vy = camera_get_view_y(view_camera[0])
}

x = 960 + vx
	if room = r_mainmenu {
	y = 610 + vy
	} else {
	y = 704 + vy	
	}

audio_sound_pitch(m_mainmenu,pitch)

name = steam_get_persona_name()
for(var i = 0; i <= 10; i++;)
        {
steam_name[i] = ""
steam_score[i] = 0
steam_rank[i] = 0
		}
score_get = steam_download_scores("Cog Distance", 1, 10);


foundrank = 0
alarm[0] = 10