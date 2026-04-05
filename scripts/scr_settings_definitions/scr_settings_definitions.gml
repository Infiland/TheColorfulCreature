enum STYPE { TOGGLE, MULTI, CATEGORY, ACTION, SLIDER, CONTROL, LANGUAGE }

function scr_settings_definitions() {
	return [
		// ===== MAIN HUB (choosesettings = 0) =====
		// Category headers (these have localization keys)
		{ type: STYPE.CATEGORY, menu: 0, col: 32,  row: 0, label: "CHANGE_VISUALS",   use_loc: true, target_menu: 1, info: 21, header_label: "CHANGE_VISUALS" },
		{ type: STYPE.CATEGORY, menu: 0, col: 32,  row: 1, label: "CHANGE_AUDIO",     use_loc: true, target_menu: 2, info: 22, header_label: "CHANGE_AUDIO" },
		{ type: STYPE.CATEGORY, menu: 0, col: 32,  row: 2, label: "CHANGE_CONTROLS",  use_loc: true, target_menu: 3, info: 23, header_label: "CHANGE_CONTROLS",
		  callback: function() {
			if os_type = os_android || os_type = os_gxgames {
				if !instance_exists(o_buttonleftandroid) { instance_create(x,y,o_buttonleftandroid) }
				if !instance_exists(o_buttonrightandroid) { instance_create(x,y,o_buttonrightandroid) }
				if !instance_exists(o_buttonjumpandroid) { instance_create(x,y,o_buttonjumpandroid) }
				if !instance_exists(o_buttoninteractandroid) { instance_create(x,y,o_buttoninteractandroid) }
				if !instance_exists(o_buttonrestartandroid) { instance_create(x,y,o_buttonrestartandroid) }
				if !instance_exists(o_buttonskipandroid) { instance_create(x,y,o_buttonskipandroid) }
			}
		  }
		},
		{ type: STYPE.CATEGORY, menu: 0, col: 32,  row: 3, label: "ENABLE_DISABLE_CHEATS", use_loc: true, target_menu: 4, info: 24, header_label: "ENABLE_DISABLE_CHEATS" },
		{ type: STYPE.CATEGORY, menu: 0, col: 32,  row: 4, label: "CHANGE_LANGUAGES", use_loc: true, target_menu: 5, info: 33, header_label: "CHANGE_LANGUAGES" },

		// General settings (col 32, rows 5-7)
		{ type: STYPE.MULTI,   menu: 0, col: 32,  row: 5, gvar: "fpssettings",        label: "FPS Show",       info: 9,  max_val: 2,
		  callback: function() {
			if global.fpssettings > 0 {
				if !instance_exists(o_fpscounter) { instance_create(0,0,o_fpscounter) }
			}
			if global.fpssettings = 0 {
				if instance_exists(o_fpscounter) { instance_destroy(o_fpscounter) }
			}
		  }
		},
		{ type: STYPE.TOGGLE,  menu: 0, col: 32,  row: 6, gvar: "autopausesettings",  label: "Auto-Pause",     info: 12 },
		{ type: STYPE.TOGGLE,  menu: 0, col: 32,  row: 7, gvar: "decimalsettings",    label: "Decimal",        info: 14 },

		// General settings (col 288, rows 0-7)
		{ type: STYPE.MULTI,   menu: 0, col: 288, row: 0, gvar: "maxfps",             label: "Max FPS",        info: 30, max_val: 5,
		  options: ["60", "75", "100", "120", "144", "150"],
		  gated: true,
		  custom_cycle: true
		},
		{ type: STYPE.TOGGLE,  menu: 0, col: 288, row: 1, gvar: "objcountersettings", label: "OBJ Counter",    info: 39 },
		{ type: STYPE.TOGGLE,  menu: 0, col: 288, row: 2, gvar: "casualmode",         label: "Casual Mode",    info: 40 },
		{ type: STYPE.TOGGLE,  menu: 0, col: 288, row: 3, gvar: "autothumbnailsettings", label: "Auto-Thumbnail", info: 41,
		  callback: function() {
			if steam_get_app_id() = 1749610 {
				if !instance_exists(o_demoask) { instance_create(0,0,o_demoask) }
			}
		  },
		  demo_gate: true
		},
		{ type: STYPE.TOGGLE,  menu: 0, col: 288, row: 4, gvar: "skipintroscreensettings", label: "Skip Intro", info: 42 },
		{ type: STYPE.MULTI,   menu: 0, col: 288, row: 5, gvar: "antialiasingsettings", label: "Anti-Aliasing", info: 43, max_val: 8,
		  options: ["Off", "2x", "4x", "8x"],
		  custom_cycle: true,
		  callback: function() {
			display_reset(global.antialiasingsettings, global.vsyncsettings)
		  }
		},
		{ type: STYPE.TOGGLE,  menu: 0, col: 288, row: 6, gvar: "vsyncsettings",     label: "V-Sync",         info: 44,
		  callback: function() {
			display_reset(global.antialiasingsettings, global.vsyncsettings)
		  }
		},
		{ type: STYPE.MULTI,   menu: 0, col: 288, row: 7, gvar: "biglevelperfsettings", label: "Big Level Perf", info: 45, max_val: 2 },

		// General settings (col 544, rows 0-2)
		{ type: STYPE.TOGGLE,  menu: 0, col: 544, row: 0, gvar: "devcommentarysettings", label: "Dev Commentary", info: 46,
		  dlc_gate: 1995510
		},
		{ type: STYPE.TOGGLE,  menu: 0, col: 544, row: 1, gvar: "customsplashessettings", label: "Custom Splashes", info: 18 },
		{ type: STYPE.TOGGLE,  menu: 0, col: 544, row: 2, gvar: "noadsinmenusettings", label: "No Ads in Menu", info: 0 },

		// Online multiplayer max players slider (row 3.28 = ~18px below row 3 buttons)
		{ type: STYPE.SLIDER,  menu: 0, col: 544, row: 3.28, gvar: "netmaxplayers", label: "Max Players", info: 50,
		  soundchange_id: 4, slider_min: 2, slider_max: 256, slider_integer: true, slider_beginx_offset: 640
		},

		// ===== VISUAL SETTINGS (choosesettings = 1) =====
		{ type: STYPE.MULTI,   menu: 1, col: 32,  row: 0, gvar: "stars",             label: "Stars",          info: 1,  max_val: 2 },
		{ type: STYPE.MULTI,   menu: 1, col: 32,  row: 1, gvar: "whiteblock",        label: "Blocks",         info: 2,  max_val: 2 },
		{ type: STYPE.TOGGLE,  menu: 1, col: 32,  row: 2, gvar: "itempar",           label: "Item Particles", info: 3 },
		{ type: STYPE.MULTI,   menu: 1, col: 32,  row: 3, gvar: "playerpar",         label: "Player Particles", info: 4, max_val: 2 },
		{ type: STYPE.TOGGLE,  menu: 1, col: 32,  row: 4, gvar: "background",        label: "Background",     info: 8 },
		{ type: STYPE.TOGGLE,  menu: 1, col: 32,  row: 5, gvar: "vignettesettings",  label: "Vignette",       info: 13 },
		{ type: STYPE.TOGGLE,  menu: 1, col: 32,  row: 6, gvar: "visual3dsettings",  label: "3D Effect",      info: 15 },
		{ type: STYPE.TOGGLE,  menu: 1, col: 32,  row: 7, gvar: "blockbackgroundsettings", label: "Block Background", info: 17 },

		// Col 288, rows 0-4
		{ type: STYPE.MULTI,   menu: 1, col: 288, row: 0, gvar: "colorblindsettings", label: "Color Blind",   info: 16, max_val: 4,
		  options: ["Off", "Protanopia", "Deuteranopia", "Tritanopia", "Grayscale"],
		  custom_cycle: true,
		  callback: function() {
			var next_mode = global.colorblindsettings
			var was_grayscale = (global.isgrayscale == true)
			if (next_mode == 0) {
				if (instance_exists(o_ColorBlindnessSimulation)) {
					with (o_ColorBlindnessSimulation) { enabled = false; mode = 0 }
				}
			} else if (!instance_exists(o_ColorBlindnessSimulation)) {
				instance_create(0, 0, o_ColorBlindnessSimulation)
			} else {
				with (o_ColorBlindnessSimulation) { enabled = true; mode = next_mode }
			}
			global.isgrayscale = (next_mode == 4)
			if (was_grayscale && !global.isgrayscale) {
				if (room != r_settings) {
					if (global.endless == 0) {
						if (global.challenges == 0) { scr_saveachievements() }
					}
				}
			}
		  }
		},
		{ type: STYPE.TOGGLE,  menu: 1, col: 288, row: 1, gvar: "fullscreen",        label: "Fullscreen",     info: 19,
		  callback: function() {
			if global.fullscreen = 1 {
				window_enable_borderless_fullscreen(true)
				window_set_fullscreen(true)
			} else {
				window_set_fullscreen(false)
			}
		  }
		},
		{ type: STYPE.TOGGLE,  menu: 1, col: 288, row: 2, gvar: "watershadersettings", label: "Water Shader", info: 27 },
		{ type: STYPE.TOGGLE,  menu: 1, col: 288, row: 3, gvar: "gunvisibilitysettings", label: "Gun Visibility", info: 29 },
		{ type: STYPE.TOGGLE,  menu: 1, col: 288, row: 4, gvar: "oldGSsettings",     label: "Old Game Snap",  info: 34 },

		// Graphics Presets (stacked in third column)
		{ type: STYPE.ACTION,  menu: 1, col: 560, row: 0, label: "Poor",   info: -1,
		  callback: function() {
			global.vignettesettings = 0; global.background = 0; global.stars = 0
			global.itempar = 0; global.playerpar = 0; global.blockbackgroundsettings = 0
			global.whiteblock = 0; global.visual3dsettings = 0; global.watershadersettings = 0
			scr_savesettings()
			if !steam_get_achievement("POTATO_SETTINGS") { steam_set_achievement("POTATO_SETTINGS") }
		  }
		},
		{ type: STYPE.ACTION,  menu: 1, col: 560, row: 1, label: "Low",    info: -1,
		  callback: function() {
			global.vignettesettings = 1; global.background = 1; global.stars = 0
			global.itempar = 1; global.playerpar = 0; global.blockbackgroundsettings = 1
			global.whiteblock = 0; global.visual3dsettings = 0; global.watershadersettings = 1
			scr_savesettings()
		  }
		},
		{ type: STYPE.ACTION,  menu: 1, col: 560, row: 2, label: "Medium", info: -1,
		  callback: function() {
			global.vignettesettings = 1; global.background = 1; global.stars = 1
			global.itempar = 1; global.playerpar = 1; global.blockbackgroundsettings = 1
			global.whiteblock = 1; global.visual3dsettings = 0; global.watershadersettings = 1
			scr_savesettings()
		  }
		},
		{ type: STYPE.ACTION,  menu: 1, col: 560, row: 3, label: "High",   info: -1,
		  callback: function() {
			global.vignettesettings = 1; global.background = 1; global.stars = 2
			global.itempar = 1; global.playerpar = 2; global.blockbackgroundsettings = 1
			global.whiteblock = 2; global.visual3dsettings = 1; global.watershadersettings = 1
			scr_savesettings()
			if !steam_get_achievement("BENCHMARK") { steam_set_achievement("BENCHMARK") }
		  }
		},

		// ===== AUDIO SETTINGS (choosesettings = 2) =====
		{ type: STYPE.TOGGLE,  menu: 2, col: 32,  row: 0, gvar: "musicdistortionsettings", label: "Music Distortion", info: 11 },
		{ type: STYPE.TOGGLE,  menu: 2, col: 32,  row: 1, gvar: "troopvoicelinesettings", label: "Troop Voicelines", info: 20 },

		// Audio sliders
		{ type: STYPE.SLIDER,  menu: 2, col: 32,  row: 2, gvar: "musicvolume",  label: "Music Volume",  info: 6,  soundchange_id: 1 },
		{ type: STYPE.SLIDER,  menu: 2, col: 32,  row: 3, gvar: "soundvolume",  label: "Sound Volume",  info: 7,  soundchange_id: 2 },
		{ type: STYPE.SLIDER,  menu: 2, col: 32,  row: 4, gvar: "mastervolume", label: "Master Volume", info: 28, soundchange_id: 3 },

		// ===== CHEATS (choosesettings = 4) =====
		{ type: STYPE.ACTION,  menu: 4, col: 32,  row: 0, gvar: "cheats",       label: "Turn on Cheats", info: 38,
		  callback: function() {
			if global.cheats = 0 { global.cheats = 1 }
		  },
		  one_way: true
		},
		{ type: STYPE.TOGGLE,  menu: 4, col: 32,  row: 1, gvar: "easy",         label: "Easy Mode",      info: 5,
		  cheat_gated: true,
		  callback: function() {
			if global.easy = 0 {
				scr_loadskins()
				scr_loadstats()
			} else {
				global.cheats = 1
			}
		  }
		},
		{ type: STYPE.TOGGLE,  menu: 4, col: 32,  row: 2, gvar: "infinitelivessettings", label: "Infinite Lives", info: 25,
		  cheat_gated: true,
		  callback: function() { if global.infinitelivessettings = 1 { global.cheats = 1 } }
		},
		{ type: STYPE.TOGGLE,  menu: 4, col: 32,  row: 3, gvar: "noclip",       label: "Noclip",         info: 36,
		  cheat_gated: true,
		  callback: function() { if global.noclip = 1 { global.cheats = 1 } }
		},
		{ type: STYPE.TOGGLE,  menu: 4, col: 32,  row: 4, gvar: "berserk",      label: "Berserk",        info: 37,
		  cheat_gated: true,
		  callback: function() { if global.berserk = 1 { global.cheats = 1 } }
		},
		{ type: STYPE.TOGGLE,  menu: 4, col: 32,  row: 5, gvar: "visiblethings", label: "Visible Things", info: 47,
		  cheat_gated: true,
		  callback: function() { if global.visiblethings = 1 { global.cheats = 1 } }
		},
		{ type: STYPE.TOGGLE,  menu: 4, col: 32,  row: 6, gvar: "managablejump", label: "Managable Jump", info: 48,
		  cheat_gated: true,
		  callback: function() { if global.managablejump = 1 { global.cheats = 1 } }
		},

		// ===== CONTROLS (choosesettings = 3) =====
		{ type: STYPE.TOGGLE,  menu: 3, col: 170, row: 0, gvar: "skiplevelholdsettings", label: "Skip Level Hold", info: 32 },
		{ type: STYPE.TOGGLE,  menu: 3, col: 426, row: 0, gvar: "controllervibrationsettings", label: "Controller Vibration", info: 49 },
	]
}
