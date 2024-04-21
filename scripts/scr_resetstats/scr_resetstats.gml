function scr_reloadstats(){
//Stats
global.totaldeaths = 0
global.totaltime = 0
global.totaljumps = 0
global.totalcoins = 0
global.totalskips = 0
global.totalpickups = 0
global.totalnormalpickups = 0
global.totalgravitypickups = 0
global.totalspeedpickups = 0
global.totalusepickups = 0
global.totalkeypickups = 0
global.totalportal = 0
global.totaltorchpickups = 0
global.totallevelcompleted = 0
global.totalendlesslevelcompleted = 0 //Unused
global.customlevelcompleted = 0
global.totalgunshots = 0
global.totalgunpickups = 0
global.totalammopickups = 0
global.totaldestroyedboxes = 0
global.totalenemykills = 0
global.total1ups = 0
global.totalrocketkills = 0
global.totaloxygenpickups = 0
global.creditscurrency = 0 //Not Quest
global.customERunlock = 0 //Not Quest
global.oldERunlock = 0 //Not Quest
global.totaldjumppickups = 0
global.totalblocksbroken = 0
global.wheeltimeleft = 0 //Not Quest
global.wheelskincooldown = 0 //Not Quest
global.totalquests = 0 //Unused

//Deaths
global.totalblockdeaths = 0
global.totalrestartdeaths = 0
global.totalspikedeaths = 0
global.totalinvisiblespikedeaths = 0
global.totalverticalspikedeaths = 0
global.totalhorizontalspikedeaths = 0
global.totalgoldspikedeaths = 0
global.totalweirdspikedeaths = 0
global.totalvoiddeaths = 0
global.totalfiredeaths = 0
global.totallavadeaths = 0
global.totalbulletdeaths = 0
global.totalrocketdeaths = 0
global.totaltroopdeaths = 0
global.totalwaterdeaths = 0
}

function scr_reloadquests(){
//Stats Related
//QUEST VARIABLES ARE USED IN INCREASE_STAT
global.QUESTdeaths = 0
global.QUESTtime = 0
global.QUESTjump = 0
global.QUESTcoins = 0
global.QUESTnormalpickups = 0
global.QUESTgravitypickups = 0
global.QUESTspeedpickups = 0
global.QUESTusepickups = 0
global.QUESTkeypickups = 0
global.QUESTportal = 0
global.QUESTtorchpickups = 0
global.QUESTlevelcompleted = 0
global.QUESTcustomlevel = 0
global.QUESTgunshots = 0
global.QUESTgunpickups = 0
global.QUESTammopickups = 0
global.QUESTdestroyedboxes = 0
global.QUESTenemykills = 0
global.QUEST1ups = 0
global.QUESTrocketkills = 0
global.QUESToxygenpickups = 0
global.QUESTdjumppickups = 0
global.QUESTblocksbroken = 0

global.QUESTblockdeaths = 0
global.QUESTrestartdeaths = 0
global.QUESTspikedeaths = 0
global.QUESTinvisiblespikedeaths = 0
global.QUESTverticalspikedeaths = 0
global.QUESThorizontalspikedeaths = 0
global.QUESTgoldspikedeaths = 0
global.QUESTweirdspikedeaths = 0
global.QUESTvoiddeaths = 0
global.QUESTfiredeaths = 0
global.QUESTlavadeaths = 0
global.QUESTbulletdeaths = 0
global.QUESTrocketdeaths = 0
global.QUESTtroopdeaths = 0
global.QUESTwaterdeaths = 0
//Boolean Related
}