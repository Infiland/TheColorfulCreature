if instance_exists(o_progressask) { exit }

if !instance_exists(o_quitask) {
audio_sound_pitch(m_mainmenu,1)
window_set_cursor(cr_default)
global.choosesettings = 0
if room = r_mainmenu {
room_goto(r_settings);
steam_set_rich_presence("Menu","Lookin' at settings")
} else {
instance_create(x,y,o_settingspausemenu)
AdMob_Banner_Hide()
}}