if global.choosesettings != 1 { exit }

global.playerpar += 1
if global.playerpar > 2 {
global.playerpar = 0	
}
scr_savesettings()