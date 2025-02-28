if keyboard_check(vk_control) {

instance_destroy(o_leveleditormenusetup)
instance_destroy(o_allbackgrounds)
instance_destroy(o_chooseleveleditorlevel)
//scr_loadleveleditor()

if global.levelname != "" {
instance_create(x,y,o_levelreloadagain)
if !steam_get_achievement("LOAD_LEVEL") { //Load Level
steam_set_achievement("LOAD_LEVEL") 
}
} else {
	instance_destroy(o_savedandloaded)
	box = instance_create(x,y,o_savedandloaded)
	with(box) {
	image_index = 3	
	}
	
}


show_debug_message(global.levelname)

} else {
	event_perform(ev_mouse,ev_left_press)
}