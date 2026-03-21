if global.choosesettings = 0 {
	instance_activate_object(o_settings)
	instance_activate_object(o_pausescreen)
	instance_activate_object(o_givefeedback)
	
	if global.challenges = 1 {
		instance_activate_object(o_restartchallengebutton)
	}
	
	instance_destroy(o_allsettings)
	instance_destroy(o_settingbutton)
	instance_destroy(o_settingslider)
	instance_destroy(o_changelanguagesettings)
	instance_destroy(o_controlsbuttonsettings)
	instance_destroy(o_defaultkeysbuttonsetings)
	scr_savesettings()
	instance_destroy(o_info)
	instance_destroy(o_animatedtext)
	instance_destroy()
	
} else { 
	scr_savesettings()
	global.choosesettings = 0 
}