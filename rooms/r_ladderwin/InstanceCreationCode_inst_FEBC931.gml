audio_stop_all()
instance_destroy(o_pausesystem)
instance_destroy(o_timecounter)
instance_destroy(o_time)
instance_destroy(o_fadecontroller)
instance_destroy(o_deathcounter)
instance_destroy(o_musicdistortion)
instance_destroy(o_ammocounter)
global.challenges = 1
if global.easy = 0 {
global.skin019 = 1
global.creditscurrency += 5
if global.ladderchallengetime > global.time {
global.ladderchallengetime = global.time
}
scr_savechallengetime()
}
scr_saveskins()
if global.music = 1 {
audio_play_sound(m_goodending,0,0)
}