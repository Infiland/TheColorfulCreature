/// @description Click to start
if locked = 0 {
	with(o_animatedtext) {
text = self.text
}
if steam_get_app_id() = 1749610 {
if month > 2 {
if !instance_exists(o_demoask) {instance_create(x,y,o_demoask)}
exit
}}
global.calendarmonth = month
scr_loadrewardscalendar()

instance_create(x,y,o_calendarweekcounter)
instance_create(x,y,o_calendarbuttonmaker)
instance_create(x,y,o_calendarrewardmaker)
instance_destroy(o_monthbuttonC)
}