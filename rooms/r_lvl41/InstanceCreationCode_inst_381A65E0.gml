if steam_get_app_id() = 1749610 {
audio_stop_all()
audio_play_sound(m_goodending,0,1)
room_goto(r_demofinishedscreen)
hidehud()
exit
}

music3bugfix()
audio_stop_sound(m_warp);
audio_stop_sound(m_bosswin);

if global.dailylevel = 1 { exit }
if global.levelselect = 1 { exit }
if global.cheats = 1 { exit }
if global.endless = 1 { exit }

if global.world2time = 0 {
instance_create(x,y,o_showworldtimeHUD)	
}

global.world2time = global.time - global.world1time
if global.world2time > 30 {
steam_upload_score("World 2 Time", global.world2time * 1000);
}

if global.world2time < 180 {
if !steam_get_achievement("WORLD_2_QUICK") { steam_set_achievement("WORLD_2_QUICK") }
}