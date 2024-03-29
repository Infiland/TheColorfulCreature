global.delta = delta_time / 1000000;

if global.pause = 0 {
if room != r_tale && !instance_exists(o_hatshopmenu){
global.time += global.delta
global.androidadtimer -= global.delta
//global.time = ((get_timer() - starttime)+pausetime)/ 1000000;
}} else {
	pausetime += global.delta
	if global.androidadtimer > 300 {
	global.androidadtimer += 0.01
	}
}
if room = r_leveleditor {
global.LESavedWinTime += global.delta
}
global.totaltime += global.delta
if global.wheeltimeleft >= 0 {
global.wheeltimeleft -= global.delta
}