var _available = CER_start_availability();
islvl = _available.levels;
ismus = _available.music;
if (!islvl || !ismus) {
    show_message_async(loc("CER_SELECT_LEVELS_AND_MUSIC"));
    exit;
}
if (!CERrandommusic()) exit;

global.endlessrunmode = 3
global.endless = 1
if !achievement_earned("YOUR_OWN_ENDLESS_RUN") { achievement_award("YOUR_OWN_ENDLESS_RUN") }
audio_stop_all()
instance_create(x,y,o_levelcounter)
loadhud()
global.hardmodelives = global.CERLives
global.time = 0
global.endlessmusicchange = global.CERMusicChange
global.endless1upchange = global.CER1upChange
randomlevel()
randomsong()
