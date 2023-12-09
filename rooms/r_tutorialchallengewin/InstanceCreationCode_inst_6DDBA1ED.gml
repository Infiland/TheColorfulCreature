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
if global.hat001 != 1 {
global.hat001 = 0
}
global.creditscurrency += floor(2 * global.creditsmultiplier)
}
scr_savehats()
audio_play_sound(m_goodending,0,1)