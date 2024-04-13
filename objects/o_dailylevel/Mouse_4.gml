if global.calendarcurrentyear = 2022 {
if global.calendarcurrentmonth = 1 {
if global.calendarcurrentday = 1 {
exit;
	}}}

if locked = 1 { exit }
if !instance_exists(o_progressask) {
window_set_cursor(cr_default)

random_set_seed(seed)
var i = irandom(319)
global.dailylevel = 1
scr_dailylevelload(i)
audio_stop_all()
instance_destroy(o_coincounter)
steam_set_rich_presence("Menu","Playing Daily Level")
}