if global.choosesettings != 1 { exit }

global.stars += 1
if global.stars > 2 {global.stars = 0}
scr_savesettings()