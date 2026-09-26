if global.choosesettings != 1 { exit }

global.vignettesettings = 0
global.background = 0
global.stars = 0
global.itempar = 0
global.playerpar = 0
global.blockbackgroundsettings = 0
global.whiteblock = 0
global.visual3dsettings = 0
global.watershadersettings = 0
scr_savesettings()
if !achievement_earned("POTATO_SETTINGS") { //Potato Settings
achievement_award("POTATO_SETTINGS")
}
