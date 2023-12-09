if global.choosesettings != 1 { exit }

global.whiteblock += 1
if global.whiteblock > 2 {
global.whiteblock = 0	
}
scr_savesettings()