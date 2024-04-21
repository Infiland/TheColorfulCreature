if !instance_exists(o_questsmenu) {
	newquests = 0
	if global.QUESTday != global.calendarcurrentday {
		scr_reloadquests()	
	}
	instance_create(x,y,o_questsmenu)
}