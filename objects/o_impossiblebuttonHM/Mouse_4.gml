/// @description Click to start
if global.hardmodeunlock > 3 {
if room = r_hardmodediff {
window_set_cursor(cr_default)
room_goto(r_lvl1)
loadhud()
global.hardmode = 1
global.hardmodelives = 3;
global.hardmodedifficulty = 4
global.hatmerchantdiscount = 0.8
audio_stop_sound(m_mainmenu);
}}