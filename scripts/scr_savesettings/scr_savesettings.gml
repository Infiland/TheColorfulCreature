function scr_savesettings() {
	var directory = directory_set("//Save Files/")
	
	if (file_exists(directory + "Settings.sav")) file_delete(directory + "Settings.sav");
	ini_open(directory + "Settings.sav");
	//Settings
	ini_write_real("Settings","Star Settings",global.stars);
	ini_write_real("Settings","White Block Settings",global.whiteblock);
	ini_write_real("Settings","Item Particles Settings",global.itempar);
	ini_write_real("Settings","Player Settings",global.playerpar);
	ini_write_real("Settings","Backround",global.backround);
	ini_write_real("Settings","FPS Show",global.fpssettings);
	ini_write_real("Settings","Music Volume",global.musicvolume);
	ini_write_real("Settings","Sound Volume",global.soundvolume);
	ini_write_real("Settings","Master Volume",global.mastervolume);
	ini_write_real("Settings","Auto Pause",global.autopausesettings);
	ini_write_real("Settings","Music Distortion",global.musicdistortionsettings);
	ini_write_real("Settings","Vignette",global.vignettesettings);
	ini_write_real("Settings","Decimal",global.decimalsettings);
	ini_write_real("Settings","3D",global.visual3dsettings);
	ini_write_real("Settings","ColorBlind",global.colorblindsettings);
	ini_write_real("Settings","Block Background",global.blockbackgroundsettings);
	ini_write_real("Settings","Troop Voiceline",global.troopvoicelinesettings);
	ini_write_real("Settings","Water Shader",global.watershadersettings);
	ini_write_real("Settings","Gun Visibility",global.gunvisibilitysettings);
	ini_write_real("Settings","Max FPS",global.maxfps);
	ini_write_real("Settings","Skip Level Hold",global.skiplevelholdsettings);
	ini_write_real("Settings","Old GS",global.oldGSsettings);
	ini_write_real("Settings","OBJ Counter",global.objcountersettings);
	ini_write_real("Settings","Language",global.language);
	ini_write_real("Settings","Casual Mode",global.casualmode);
	ini_write_real("Settings","Auto-Thumbnail",global.autothumbnailsettings);
	ini_write_real("Settings","Skip Intro Screen",global.skipintroscreensettings);
	ini_write_real("Settings","Antialiasing",global.antialiasingsettings);
	ini_write_real("Settings","V-Sync",global.vsyncsettings);
	ini_write_real("Settings","Big Level Perf",global.biglevelperfsettings);
	ini_write_real("Settings","Custom Splashes",global.customsplashessettings)
	ini_write_real("Settings","Hats Autoscale",global.customhatautoscale)
	ini_write_real("Settings","Fullscreen",global.fullscreen);
	ini_write_real("Settings","No Ads in Menu",global.noadsinmenusettings)
	//Controls Config
	ini_write_string("Controls","Restart",global.controlsrestart);
	ini_write_string("Controls","Skip Level",global.controlsskiplevel);
	ini_write_string("Controls","Interact",global.controlsinteract);
	ini_write_string("Controls","Jump",global.controlsjump);
	ini_write_string("Controls","Move Left",global.controlsmoveleft);
	ini_write_string("Controls","Move Right",global.controlsmoveright);
	ini_write_real("Controls","Controller Vibration",global.controllervibrationsettings)
	ini_close();


}
