var i = 0
for(i=0;i<checklvl;i++) {
var lvl = variable_global_get("CERL" + string(i))
if lvl = 1 { islvl = true }
}

for(i=0;i<checkmus;i++) {
var mus = variable_global_get("CERM" + string(i))
if mus = 1 { ismus = true }
}

if islvl = true && ismus = true {
global.endlessrunmode = 3
global.endless = 1
if !steam_get_achievement("YOUR_OWN_ENDLESS_RUN") { steam_set_achievement("YOUR_OWN_ENDLESS_RUN") }
audio_stop_all()
CERrandommusic()
instance_create(x,y,o_levelcounter)
loadhud()
global.hardmodelives = global.CERLives
global.time = 0
global.endlessmusicchange = global.CERMusicChange
global.endless1upchange = global.CER1upChange
randomlevel()
randomsong()
rousr_dissonance_set_details("Playing Custom Endless Run")
}