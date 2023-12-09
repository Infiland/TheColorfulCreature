/// @description Click to start
if global.hardmodeunlock > 2 {
if room = r_hardmodediff {
window_set_cursor(cr_default)
room_goto(r_lvl1)
loadhud()
global.hardmode = 1
global.hardmodelives = 15;
global.hardmodedifficulty = 3
global.hatmerchantdiscount = 0.85
audio_stop_sound(m_mainmenu);
}}