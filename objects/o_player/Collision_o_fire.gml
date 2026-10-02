if (!timing_is_tick()) exit;
if global.pause = 0 {
firedeath -= 1
}
if global.easy = 0 {
if firedeath < 0 {
	if !achievement_earned("TORCHERD") { achievement_award("TORCHERD") }
	increase_stat("totalfiredeaths","QUESTfiredeaths",1)
	death() }
}
