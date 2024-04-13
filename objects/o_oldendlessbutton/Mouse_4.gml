if global.oldERunlock = 0 {
if global.creditscurrency >= cost {	
global.creditscurrency -= cost
audio_play_sound(snd_cashsound,0,0)
global.oldERunlock = 1
locked = 0
scr_savestats()
}} else {
global.endlessrunmode = 2
global.endless = 1
global.chooserandommusic = irandom_range(1,24)
audio_stop_all()
instance_create(x,y,o_levelcounter)
loadhud()
global.hardmodelives = 5
global.time = 0
randomlevel()
randomsong()

global.endlessmusicchange = 10
global.endless1upchange = 10
}

window_set_cursor(cr_default)