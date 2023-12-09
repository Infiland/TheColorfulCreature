if global.choosesettings != 1 { exit }

if global.itempar = 1 {
global.itempar = 0	
}
else { global.itempar = 1 }
scr_savesettings()