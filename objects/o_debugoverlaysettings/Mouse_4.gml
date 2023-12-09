if global.choosesettings != 4 { exit }
if global.cheats = 0 { exit }

if global.debugoverlaysettings = 1 { global.debugoverlaysettings = 0 } else  {
	global.debugoverlaysettings = 1 }
	
show_debug_overlay(global.debugoverlaysettings)