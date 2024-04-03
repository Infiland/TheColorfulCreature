function scr_loading(){
randomize()

//AUDIO EFFECTS
global._ef_water = audio_effect_create(AudioEffectType.LPF2)
global._ef_water.q = 5;
global._ef_water.cutoff = 20000;
audio_bus_main.effects[0] = global._ef_water;

global._ef_gain = audio_effect_create(AudioEffectType.Gain)
global._ef_gain.gain = 1;
audio_bus_main.effects[1] = global._ef_gain;

/*global.classicfont = font_add("Fonts\\fnt_classic.ttf",20,false,false,32,128)
global.coolfont = font_add("Fonts\\fnt_cool.ttf",15,false,false,32,128)
global.cool2font = font_add("Fonts\\fnt_cool2.ttf",15,false,false,32,128)
global.gamemodefont = font_add("Fonts\\fnt_gamemode.ttf",36,false,false,1040,1200)
global.completefont = font_add("Fonts\\fnt_complete.ttf",36,false,false,1040,1200)*/

global.classicfont = fnt_classic
global.coolfont = fnt_cool
global.cool2font = fnt_cool2
global.gamemodefont = fnt_gamemode
global.completefont = fnt_complete
global.deathfont = fnt_death


font_add_enable_aa(false)

//font_enable_sdf(global.classicfont,true)
//font_enable_sdf(global.coolfont,true)
//font_enable_sdf(global.cool2font,true)
/*font_enable_sdf(global.coolfont,true)
font_enable_sdf(global.gamemodefont,true)
font_enable_sdf(global.deathfont,true)
font_enable_sdf(fnt_skip,true)
font_enable_sdf(fnt_secret1,true)
font_enable_sdf(fnt_multiplayerfont,true)
font_enable_sdf(global.completefont,true)
font_enable_sdf(fnt_mainmenu,true)
font_enable_sdf(fnt_deathcyrillic,true)*/

//Move/Create Save Files

var directory = directory_set("//Save Files/")

if !directory_exists(directory) {
		directory_create(directory)
		file_copy("Achievements.sav",directory + "Achievements.sav")
		file_delete("Achievements.sav"); //Achievements
		file_copy("Stats.sav",directory + "Stats.sav")
		file_delete("Stats.sav"); //Stats
		file_copy("Skins.sav",directory + "Skins.sav")
		file_delete("Skins.sav"); //Skins
		file_copy("Settings.sav",directory + "Settings.sav")
		file_delete("Settings.sav"); //Settings
		file_copy("Hats.sav",directory + "Hats.sav")
		file_delete("Hats.sav"); //Hats
		file_copy("Hardmode.sav",directory + "Hardmode.sav")
		file_delete("Hardmode.sav"); //Hardmode
		file_copy("Endless.sav",directory + "Endless.sav")
		file_delete("Endless.sav"); //Endless
		file_copy("SaveFile.sav",directory + "SaveFile.sav")
		file_delete("SaveFile.sav"); //Save File
		file_copy("ChallengeTime.sav",directory + "ChallengeTime.sav")
		file_delete("ChallengeTime.sav"); //Challenge Time
		file_copy("ChallengeDeaths.sav",directory + "ChallengeDeaths.sav")
		file_delete("ChallengeDeaths.sav"); //Challenge Deaths
		
		file_delete("Calendar.sav"); //Calendar
}

global.CUSTOMhat = ""

global.challengescroll = 0
global.asteroidskeypoints = 0
global.foundcog = 0
global.asteroidfun = 0

global.color = 0

global.playercount = 0
global.creditsmultiplier = 1
global.wheelmultiplier = 1

global.portalfreeMU = 1
global.fileID = 0
global.dailylevel = 0
global.achievementsscroll = 0
global.customlevelsscroll = 0
global.customlevelsscrollmax = 0
global.stars = 2
global.whiteblock = 1
global.itempar = 1
global.playerpar = 1
global.nostalgia = 0
global.easy = 0
global.backround = 1
global.challenges = 0

global.gamenews = 0

global.debugoverlaysettings = 0
global.fpssettings = 0
global.hatsettings = 1
global.musicvolume = 0.5
global.soundvolume = 0.5
global.mastervolume = 0.5
audio_master_gain(global.mastervolume)
global.hardmode = 0
global.levelselect = 0
global.autopausesettings = 0
global.hardmodedifficulty = 0
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
global.skipintroscreensettings = 0
global.devcommentarysettings = 0
global.customsplashessettings = 0
global.maxfps = 60
global.world1 = 0
global.world2 = 0
global.world3 = 0
global.world4 = 0
global.world5 = 0
global.checkdeposit = false
global.writingmode = 0
global.leveleditorstring = ""
global.leveleditormusic = 0
global.leveleditorversion = 1
global.LEbuttonpage = 1
global.LEBackground = 0
global.LEStarRotation = 0
global.LEBlockBackgroundRotation = 0
global.LEDiamondMedalTime = 35
global.LESavedWinTime = 0
global.LELevelWidthBlocks = 32
global.LELevelHeightBlocks = 22
global.LEStarStyle = 0
global.LEBlockStyle = 0
global.LEFog = 0
global.endless = 0
global.chooserandomlevel = 0
global.chooserandommusic = 0
global.endlesslevel = 0
global.endlesslevelhighscore = 0
global.newendlesslevelhighscore = 0
global.choosesettings = 0
global.skinpage = 1
global.hatpage = 1
global.itempage = 1
global.chosenmusicER = 0
global.endless1upchange = 10
global.endlessrunmode = 1
global.noclip = 0
global.berserk = 0
global.visiblethings = 0
global.managablejump = 0
global.objcountersettings = 0
global.autothumbnailsettings = 1
global.antialiasingsettings = 0
global.vsyncsettings = 0
global.biglevelperfsettings = 0
global.leaderboardselect = 0
global.hatmerchantdiscount = 1
global.friendleaderboardsettings = 0
global.customhatautoscale = 1
global.controllervibrationsettings = 1
global.fullscreen = 0

//Workshop
global.workshopfolder = ""
global.workshop = 0

global.world1time = 0
global.world2time = 0
global.world3time = 0
global.world4time = 0
global.world5time = 0

global.demo = 0
global.language = 0
global.checkpointX = 0
global.checkpointY = 0
global.checkpointCOLOR = -1
global.checkpointAMMO = 0
global.checkpointGUN = false
global.casualmode = 0

global.worldProgression = 1

global.cheats = 0
scr_loadendless()

//Daily level
global.dailylevelstreak = 0
global.dailylevelhighstreak = 0

global.dailylevelday = 1
global.dailylevelmonth = 1
global.dailylevelyear = 2021

scr_loaddaily()

//Calendar
global.calendar = 0
global.calendaryear = 2022
global.calendarmonth = 1
global.calendarweek = 1
global.calendarday = 1

global.calendardifficulty = 2

global.calendar2022unlock = 0

global.calendarcurrentyear = 2022
global.calendarcurrentmonth = 4
global.calendarcurrentday = 2
global.calendarcurrentweek = 1
global.newcalendarrecord = 0
global.newcalendarseed = 0

global.calendarday1 = 0
global.calendarday2 = 0
global.calendarday3 = 0
global.calendarday4 = 0
global.calendarday5 = 0
global.calendarday6 = 0
global.calendarday7 = 0

global.newcalendarlevel1 = 0
global.newcalendarlevel2 = 0
global.newcalendarlevel3 = 0
global.newcalendarlevel4 = 0
global.newcalendarlevel5 = 0
global.newcalendarlevel6 = 0
global.newcalendarlevel7 = 0
global.newcalendarrewarded = 0

global.newcalendarreward = 0

global.calendarday1required = 0
global.calendarday2required = 0
global.calendarday3required = 0
global.calendarday4required = 0
global.calendarday5required = 0
global.calendarday6required = 0
global.calendarday7required = 0
global.calendarrewarded = 0
scr_loadcalendar()
scr_loadnewcalendar()
global.calendardifficulty = 3
scr_loadnewcalendar()
global.calendardifficulty = 1
scr_loadnewcalendar()

/*var directory = working_directory + "/Save Files//Calendar/"
if !(file_exists(directory + "Calendar.sav")) {
	scr_savecalendar()
}*/

//Controls
global.controlsskiplevel = "C"
global.controlsinteract = "X"
global.controlsjump = "Z"
global.controlsmoveright = "39"
global.controlsmoveleft = "37"
global.controlsrestart = "R"
scr_loadsettings()
game_set_speed(global.maxfps, gamespeed_fps);

if global.fullscreen = 1 {
	window_enable_borderless_fullscreen(true);
	window_set_fullscreen(true);
	} else { 
		window_set_fullscreen(false);
}

if global.fpssettings > 0 {
instance_create(x,y,o_fpscounter)
}
instance_create(x,y,o_ColorBlindnessSimulation)	

//Stats
scr_reloadstats()
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
global.djumpchallengetime = 9999
global.cspikechallengetime = 9999
global.world7challengetime = 9999
global.invisiblechallengetime = 9999
global.breakablechallengetime = 9999
global.lunarbasechallengetime = 9999

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
global.djumpchallengedeaths = 999999
global.cspikechallengedeaths = 999999
global.world7challengedeaths = 999999
global.invisiblechallengedeaths = 999999
global.breakablechallengedeaths = 999999
global.lunarbasechallengedeaths = 999999

global.currentchallenge = 0
scr_loadchallengetime()
scr_loadchallengedeaths()

//Custom Endless Run
global.CESConfigure = 0
global.CERLives = 5
global.CERMusicChange = 10
global.CER1upChange = 10
global.CERyscroll = 0
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
global.multiplayerplayeritem[0] = 0
global.multiplayerplayeritem[1] = 0
global.multiplayerplayeritem[2] = 0
global.multiplayerplayeritem[3] = 0
global.multiplayerplayercontrols[0] = 0
global.multiplayerplayercontrols[1] = -1
global.multiplayerplayercontrols[2] = -2
global.multiplayerplayercontrols[3] = -3
global.multiplayerplayercontrols[4] = -4
global.customizeselectMU = 1
global.skinMUlocked = false
global.hatMUlocked = false
global.itemMUlocked = false
global.chooseminigameMU = false
global.playersleft = 0

//Achievements
global.isgrayscale = false
global.isinvisible = false
global.isreversed = false
scr_loadachievements()

/*
//Skins
global.skin[1] = 0
var skins
for(skins = 0;skins <= 100; skins++) {
	global.skin[skins] = 0 + skins
}
//Hats
var hats
for(hats = 0;hats <= 69; hats++) {
	global.hats[hats] = 0 + hats
	}*/
global.customizeselect = 1

scr_loadallcustomizables()

scr_loadskins()
scr_loadhats()
scr_loaditems()

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
if global.skin025 = 0 {
if global.hardmodeunlock > 2 {
global.skin025 = 1
}}
//Steam
global.steam_api = false
audio_group_load(Music)
//Android
global.androidadtimer = 300


//Folders
var directory = directory_set("/Custom/")
	if !directory_exists(directory) {
		directory_create(directory)
	}
	if !directory_exists(directory + "Player Skins") {
		directory_create(directory + "Player Skins")
	}
	if !directory_exists(directory + "Player Hats") {
		directory_create(directory + "Player Hats")
	}
	if !directory_exists(directory + "Player Items") {
		directory_create(directory + "Player Items")
	}
	directory_destroy(directory + "Hats")
	directory_destroy(directory + "Skins")
		
		if file_exists(game_save_id + "/Custom/README.txt") file_delete(game_save_id + "/Custom/README.txt");
		var _f = file_text_open_write(game_save_id + "/Custom/README.txt");
	    file_text_write_string(_f, string("You can customize hats! Add hats in the player hats folder, put .png images. Recommended resolution is 32x24 resolution! This is not finished and has limited functionality, hopefully the future versions will :)"));
		file_text_close(_f);
			if !file_exists(game_save_id + "/Custom/Custom Splash Texts.txt") {
		var _f = file_text_open_write(game_save_id + "/Custom/Custom Splash Texts.txt");
	    file_text_write_string(_f, string("Go to local files or %appdata% to change this text\n[rainbow][wave]You can use text like this:"));	
		file_text_close(_f);
		}
	}
	var directory = directory_set("/LevelEditor Files/")
	if !directory_exists(directory) {directory_create(directory)}
	
	var directory = directory_set("/Save Files/Calendar/")
		if !directory_exists(directory) {
	directory_create(directory)
	}
	var directory = directory_set("/Custom/Workshop/Medals/")
	if !directory_exists(directory) { directory_create(directory) }
	
	var directory = directory_set("/Custom/Custom Languages/")
	if !directory_exists(directory) { directory_create(directory) }

	
//Read_Me Text File
    if file_exists("Save Files/README.txt") file_delete("Save Files/README.txt");
    var _f = file_text_open_write("Save Files/README.txt");
    file_text_write_string(_f, string("You found the Local Files, congrats!\nAnyway if you are reading this, PLEASE DO NOT MODIFY THESE FILES, it is considered cheating.\nPlease use this only for bugfixing purposes.\n\nAlso if the game crashed, go to the Other folder and send it to our discord server: https://discord.gg/SSz5THd"));
    file_text_close(_f);
	file_delete("README.txt")