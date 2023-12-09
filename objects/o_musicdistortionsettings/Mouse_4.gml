if global.choosesettings != 2 { exit }

if global.musicdistortionsettings = 1 { global.musicdistortionsettings = 0 }
else { global.musicdistortionsettings = 1 }
scr_savesettings()