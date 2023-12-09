/// @description Click to start
if global.hardmodeunlock > 4 {
if room = r_hardmodediff {
window_set_cursor(cr_default)
room_goto(r_lvl1)
loadhud()
global.hardmode = 1
global.hardmodelives = 1;
global.hardmodedifficulty = 5
global.hatmerchantdiscount = 0.75
audio_stop_sound(m_mainmenu);
}}