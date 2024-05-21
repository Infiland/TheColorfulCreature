function scr_loadsettings() {
	if steam_get_app_id() != 1749610 {
		
	var directory = directory_set("//Save Files/")
	
	if (file_exists(directory + "Settings.sav")) {
	ini_open(directory + "Settings.sav")
	//Settings
	global.stars = ini_read_real("Settings","Star Settings",2);
	global.whiteblock = ini_read_real("Settings","White Block Settings",1);
	global.itempar = ini_read_real("Settings","Item Particles Settings",1);
	global.playerpar = ini_read_real("Settings","Player Settings",1);
	global.backround = ini_read_real("Settings","Backround",1);
	global.fpssettings = ini_read_real("Settings","FPS Show",0);
	global.musicvolume = ini_read_real("Settings","Music Volume",0.5);
	global.soundvolume = ini_read_real("Settings","Sound Volume",0.5);
	global.mastervolume = ini_read_real("Settings","Master Volume",0.5);
	global.autopausesettings = ini_read_real("Settings","Auto Pause",0);
	global.musicdistortionsettings = ini_read_real("Settings","Music Distortion",1);
	global.vignettesettings = ini_read_real("Settings","Vignette",1);
	global.decimalsettings = ini_read_real("Settings","Decimal",0);
	global.visual3dsettings = ini_read_real("Settings","3D",0);
	global.colorblindsettings = ini_read_real("Settings","ColorBlind",0);
	global.blockbackgroundsettings = ini_read_real("Settings","Block Background",1);
	global.troopvoicelinesettings = ini_read_real("Settings","Troop Voiceline",1);
	global.watershadersettings = ini_read_real("Settings","Water Shader",1);
	global.gunvisibilitysettings = ini_read_real("Settings","Gun Visibility",1);
	global.fullscreen = ini_read_real("Settings","Fullscreen",0);
	//global.maxfps = ini_read_real("Settings","Max FPS",60);
	global.skiplevelholdsettings = ini_read_real("Settings","Skip Level Hold",1);
	global.oldGSsettings = ini_read_real("Settings","Old GS",0);
	global.objcountersettings = ini_read_real("Settings","OBJ Counter",0);
	
	//Language return on default
	global.language = ini_read_real("Settings","Language",setLanguageDependingOnRegion());
	
	
	global.casualmode = ini_read_real("Settings","Casual Mode",1);
	global.autothumbnailsettings = ini_read_real("Settings","Auto-Thumbnail",1);
	global.skipintroscreensettings = ini_read_real("Settings","Skip Intro Screen",1);
	global.antialiasingsettings = ini_read_real("Settings","Antialiasing",0);
	global.vsyncsettings = ini_read_real("Settings","V-Sync",0);
	global.biglevelperfsettings = ini_read_real("Settings","Big Level Perf",0);
	global.customsplashessettings = ini_read_real("Settings","Custom Splashes",0);
	global.customhatautoscale = ini_read_real("Settings","Custom Splashes",1);
	//Controls
	global.controlsrestart = ini_read_string("Controls","Restart","R")
	global.controlsskiplevel = ini_read_string("Controls","Skip Level","C")
	global.controlsinteract = ini_read_string("Controls","Interact","X")
	global.controlsjump = ini_read_string("Controls","Jump","Z")
	global.controlsmoveleft = ini_read_string("Controls","Move Left","37")
	global.controlsmoveright = ini_read_string("Controls","Move Right","39")
	global.controllervibrationsettings = ini_read_real("Controls","Controller Vibration",1);
	}
	else {
	}
	}

}