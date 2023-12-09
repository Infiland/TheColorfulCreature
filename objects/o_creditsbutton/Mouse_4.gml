/// @description Click to start
if !instance_exists(o_progressask) {
if room = r_gamemode or r_support {
window_set_cursor(cr_default)
sprite_set_offset(s_playerred,16,16)
room_goto(r_credits)
sprite_prefetch(s_creditsbackround)
instance_destroy(o_star)
scr_loadhardmode()
}}
if room = r_theend {
if global.hardmodeunlock = 0 { 
	global.hardmodeunlock = 1 
	scr_savehardmode()
}}