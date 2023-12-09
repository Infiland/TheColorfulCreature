function selectlevelCUSTOM(i,text){
var xcam = camera_get_view_x(view_camera[0])+512
if mouse_check_button_released(mb_left) {
if mouse_x > xcam-300 && mouse_x < xcam+300 && mouse_y > 85-(floor(i/15)*600)+i*40 && mouse_y < 115-(floor(i/15)*600)+i*40 {
global.levelname = text
instance_destroy(o_leveleditormenusetup)
instance_destroy(o_allbackgrounds)
instance_destroy(o_chooseleveleditorlevel)
//scr_loadleveleditor()

if global.levelname != "" {
instance_create(x,y,o_levelreloadagain)
if !steam_get_achievement("LOAD_LEVEL") { //Load Level
steam_set_achievement("LOAD_LEVEL") }
} else {
	instance_destroy(o_savedandloaded)
	box = instance_create(x,y,o_savedandloaded)
	with(box) {
	image_index = 3	
	}
	
}

show_debug_message(text)
}}}