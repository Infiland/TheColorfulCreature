if global.choosesettings != 0 { exit }

if global.vsyncsettings = 0 { global.vsyncsettings = 1 }
else { global.vsyncsettings = 0 }

display_reset(global.antialiasingsettings, global.vsyncsettings);