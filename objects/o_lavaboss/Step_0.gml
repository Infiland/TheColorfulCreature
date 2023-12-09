if global.pause = 1 { 
	if global.boss4 = 1 { audio_stop_sound(m_lavatime) }
	exit }

if global.lavabuttonconfirm[1] = 1 {
if global.lavabuttonconfirm[2] = 1 {
if global.lavabuttonconfirm[3] = 1 {
if y < 280 {
if global.boss4 = 0 {
if !audio_is_playing(m_bosswin) {
audio_play_sound(m_bosswin,0,0)
audio_sound_gain(m_lavatime,0,1000)
audio_sound_gain(m_bosswin,global.musicvolume,1000)
global.boss4 = 1
scr_checkachievements()
}}
exit
}}}}

if instance_exists(o_player) {
speedup = y - o_player.y
}
var realspeedup = speedup / (650 / (1 + global.hardmode))

if image_yscale < 2.8 {
image_yscale += (0.024 + realspeedup) * (60 / global.maxfps)
}

y -= (0.1 + realspeedup) * (60 / global.maxfps)