/// @description SETTINGS & SKINS
global.stars = 2
global.whiteblock = 1
global.itempar = 1
global.playerpar = 1
global.nostalgia = 0
global.easy = 0
global.backround = 1
global.challenges = 0
global.levelselect = 0
global.fpssettings = 0
global.hatsettings = 1
global.musicvolume = 0.5
global.soundvolume = 0.5
global.mastervolume = 0.5
audio_master_gain(global.mastervolume)
global.vignettesettings = 1
global.musicdistortionsettings = 1
global.decimalsettings = 0
global.rocketexplosionsound = 0
global.visual3dsettings = 0
global.colorblindsettings = 0
global.blockbackgroundsettings = 1
global.troopvoicelinesettings = 1
global.infinitelivessettings = 0
global.watershadersettings = 1
global.gunvisibilitysettings = 1
global.skiplevelholdsettings = 1
global.oldGSsettings = 0
global.objcountersettings = 0
global.maxfps = 60
global.world1 = 0
global.world2 = 0
global.world3 = 0
global.world4 = 0
global.world5 = 0
global.checkdeposit = false
global.endless = 0
global.chooserandomlevel = 0
global.endlesslevel = 0
global.endlesslevelhighscore = 0
global.newendlesslevelhighscore = 0
global.leveleditorstring = ""
global.leveleditorversion = 1
global.choosesettings = 0
global.defaultcolorLE = 0
global.skinpage = 1
global.LEbuttonpage = 1
global.LEBackground = 0
global.LEStarRotation = 0
global.LEBlockBackgroundRotation = 0
global.LEDiamondMedalTime = 35
global.LEVerified = 0
global.autothumbnailsettings = 1
global.DiamondMedalTimeChallenge = 0

global.gameoverplayerX = 0
global.gameoverplayerY = 0

global.workshopfolder = ""
global.workshop = 0

global.world1time = 0
global.world2time = 0
global.world3time = 0
global.world4time = 0
global.world5time = 0

//Calendar
global.calendaryear = 2022
global.calendarmonth = 1

global.cheats = 0
if !(file_exists("Settings.sav")) { scr_loadsettings() }
if global.fpssettings = 1 {
instance_create(x,y,o_fpscounter)
}
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
global.customlevelcompleted = 0
global.totalgunshots = 0
global.totalgunpickups = 0
global.totalammopickups = 0
global.totaldestroyedboxes = 0
global.totalenemykills = 0
global.total1ups = 0
global.totalrocketkills = 0
global.totaloxygenpickups = 0
global.cookies = 0
global.creditscurrency = 0
global.customERunlock = 0
global.oldERunlock = 0
global.totaldjumppickups = 0
global.wheeltimeleft = 0
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
scr_loadstats()

global.challengeinfo = 0
global.tutorialchallengetime = 9999
global.ladderchallengetime = 9999
global.bigroomchallengetime = 9999
global.slipperychallengetime = 9999
global.blindchallengetime = 9999
global.troopchallengetime = 9999
global.speedchallengetime = 9999
global.spikechallengetime = 9999
global.kaizochallengetime = 9999
global.world6challengetime = 9999
global.waterchallengetime = 9999
global.movingchallengetime = 9999
global.communitychallengetime = 9999
global.invisiblechallengetime = 9999
global.breakablechallengetime = 9999

global.tutorialchallengedeaths = 999999
global.ladderchallengedeaths = 999999
global.bigroomchallengedeaths = 999999
global.slipperychallengedeaths = 999999
global.blindchallengedeaths = 999999
global.troopchallengedeaths = 999999
global.speedchallengedeaths = 999999
global.spikechallengedeaths = 999999
global.kaizochallengedeaths = 999999
global.world6challengedeaths = 999999
global.waterchallengedeaths = 999999
global.movingchallengedeaths = 999999
global.communitychallengedeaths = 999999
global.invisiblechallengedeaths = 999999
global.breakablechallengedeaths = 999999
scr_loadchallengetime()
scr_loadchallengedeaths()

//Custom Endless Run
global.CESConfigure = 0
global.CERLives = 5
global.CERMusicChange = 10
global.CER1upChange = 10
var i = 0;
for(i=0;i<30;i++) {
variable_global_set("CERL" + string(i), 1)
variable_global_set("CERM" + string(i), 1)
}

//Multiplayer
global.multiplayerplayerconfigchoose = 1
global.multiplayerplayers = 1
global.multiplayerplayerskin[0] = 0
global.multiplayerplayerskin[1] = 0
global.multiplayerplayerskin[2] = 0
global.multiplayerplayerskin[3] = 0
global.multiplayerplayerhat[0] = 0
global.multiplayerplayerhat[1] = 0
global.multiplayerplayerhat[2] = 0
global.multiplayerplayerhat[3] = 0
global.multiplayerplayercontrols[0] = 0
global.multiplayerplayercontrols[1] = -1
global.multiplayerplayercontrols[2] = -2
global.multiplayerplayercontrols[3] = -3
global.customizeselectMU = 1
global.MinigameMU = 0

//Achievements
global.isgrayscale = false
global.grayscaleachievement = false
global.isinvisible = false
global.isreversed = false
global.invisibleachievement = false
scr_loadachievements()

//Customizables
global.customizeselect = 1

scr_loadallcustomizables()

scr_loadskins()
scr_loadhats()

if global.hat003 = -1 {
if current_month = 9 {
if current_day = 3 {
global.hat003 = 0
scr_savehats()	
}}
if current_month = 11 {
if current_day = 18 {
global.hat003 = 0
scr_savehats()	
}}
}

if global.hat008 = -1 {
if current_month = 1 {
if current_day <= 7 {
global.hat008 = 0
scr_savehats()	
}}
if current_month = 12 {
if current_day >= 20 {
global.hat008 = 0
scr_savehats()	
}}
}

if global.hat009 = -1 || global.hat010 = -1 {
if current_month = 10 {
if current_day >= 20 {
global.hat009 = 0
global.hat010 = 0
scr_savehats()	
}}
}

//Hardmode
global.hardmodeunlock = 0
scr_loadhardmode()
if global.endlesslevelhighscore > 49 {
global.skin022 = 1
}
audio_stop_sound(m_mainmenu)
//Controls
global.controlsskiplevel = "C"
global.controlsinteract = "X"
global.controlsjump = "Z"
global.controlsmoveright = "39"
global.controlsmoveleft = "37"
global.controlsrestart = "R"
scr_loadsettings()