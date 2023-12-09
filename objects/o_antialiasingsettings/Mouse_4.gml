if global.choosesettings != 0 { exit }

if global.antialiasingsettings = 4 { global.antialiasingsettings += 2 }
	global.antialiasingsettings += 2
	
if global.antialiasingsettings > 8 { global.antialiasingsettings = 0 }

display_reset(global.antialiasingsettings, global.vsyncsettings);