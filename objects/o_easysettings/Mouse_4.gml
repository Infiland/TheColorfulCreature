if global.choosesettings != 4 { exit }

if image_alpha = 1 {
if global.easy = 1 {
scr_loadskins()
scr_loadstats()
global.easy = 0	
}
else {
	global.cheats = 1
	global.easy = 1
	}}