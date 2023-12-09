if global.customERunlock = 0 {
if global.creditscurrency >= cost {	
global.creditscurrency -= cost
audio_play_sound(snd_cashsound,0,0)
global.customERunlock = 1
locked = 0
scr_savestats()
}} else {
global.CESConfigure = 1 
instance_deactivate_object(o_endlessbutton)
instance_deactivate_object(o_oldendlessbutton)
instance_deactivate_object(o_customendlessbutton)
instance_deactivate_object(o_onlineleaderboardsbutton)
instance_destroy(o_onlineleaderboardsmini)
instance_destroy(o_reloadleaderboardsbutton)
instance_activate_object(o_CERSettings)
if instance_exists(o_animatedtext) {
o_animatedtext.text = loc(130)
}
}
window_set_cursor(cr_default)