if global.pause = 0 {
firedeath -= 1
}
if global.easy = 0 {
if firedeath < 0 { 
	if !steam_get_achievement("TORCHERD") { steam_set_achievement("TORCHERD") }
	global.totalfiredeaths += 1
	death() }
}