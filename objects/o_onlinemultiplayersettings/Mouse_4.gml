if global.choosesettings != 0 { exit }

if global.onlinemultiplayersettings = 1 { global.onlinemultiplayersettings = 0 }
else { global.onlinemultiplayersettings = 1 }
scr_savesettings()
