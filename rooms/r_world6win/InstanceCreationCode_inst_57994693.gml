audio_stop_all()
instance_destroy(o_pausesystem)
instance_destroy(o_timecounter)
instance_destroy(o_time)
instance_destroy(o_fadecontroller)
instance_destroy(o_deathcounter)
instance_destroy(o_musicdistortion)
instance_destroy(o_ammocounter)
global.challenges = 1
if global.cheats = 0 {
global.creditscurrency += floor(50 * global.creditsmultiplier)
global.skin[17] = 1
if global.deaths < 25 {
global.skin[18] = 1
}
}
scr_saveskins()
audio_play_sound(m_goodending,0,1)