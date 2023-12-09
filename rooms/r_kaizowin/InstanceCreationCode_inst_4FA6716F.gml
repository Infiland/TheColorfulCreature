audio_stop_all()
instance_destroy(o_pausesystem)
instance_destroy(o_timecounter)
instance_destroy(o_time)
instance_destroy(o_fadecontroller)
instance_destroy(o_deathcounter)
instance_destroy(o_musicdistortion)
global.challenges = 1
if global.cheats = 0 {
scr_savechallengetime()
global.skin002 = 1
global.creditscurrency += floor(50 * global.creditsmultiplier)
}
scr_saveskins()
audio_play_sound(m_goodending,0,1)