if global.choosesettings != 1 { exit }

global.vignettesettings = 1
global.background = 1
global.stars = 2
global.itempar = 1
global.playerpar = 2
global.blockbackgroundsettings = 1
global.whiteblock = 2
global.visual3dsettings = 1
global.watershadersettings = 1
scr_savesettings()
if !steam_get_achievement("BENCHMARK") { //Benchmark
steam_set_achievement("BENCHMARK")
}