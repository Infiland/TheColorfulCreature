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
global.skin019 = 1
global.creditscurrency += floor(7 * global.creditsmultiplier)
}
scr_saveskins()
audio_play_sound(m_goodending,0,1)