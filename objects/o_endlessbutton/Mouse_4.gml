if steam_get_app_id() = 1749610 {
if !instance_exists(o_demoask) {instance_create(x,y,o_demoask)}
exit
}

if room = r_endlessrunmenu {
global.endlessrunmode = 1
global.endless = 1
global.chooserandommusic = irandom_range(1,24)
audio_stop_all()
instance_create(x,y,o_levelcounter)
loadhud()
global.hardmodelives = 5
global.difficultyER = 1
global.difficultyincreaseER = irandom_range(4,7)
global.time = 0
randomlevel()
randomsong()
rousr_dissonance_set_details("Playing Endless Run")
rousr_dissonance_set_timestamps(0,undefined)
global.endlessmusicchange = 10
global.endless1upchange = 10
instance_create(x,y,o_difficultycounter)
} else {
room_goto(r_endlessrunmenu)
}
window_set_cursor(cr_default)