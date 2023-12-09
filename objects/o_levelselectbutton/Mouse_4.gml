/// @description Click to start
if steam_get_app_id() = 1749610 {
if !instance_exists(o_demoask) {instance_create(x,y,o_demoask)}
exit;
}

if !instance_exists(o_progressask) {
if locked = 0 {
window_set_cursor(cr_default)
room_goto(r_levelselectmenu)
}}