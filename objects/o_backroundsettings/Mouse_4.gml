if global.choosesettings != 1 { exit }

if global.background = 1 {
global.background = 0	
}
else { global.background = 1 }
scr_savesettings()