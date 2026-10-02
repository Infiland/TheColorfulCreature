if (settings_fps_input_blocked() || gamepad_remap_consume_back()) exit;
if global.choosesettings = 0 {
	timing_activate_object(o_settings)
	timing_activate_object(o_pausescreen)
	timing_activate_object(o_givefeedback)
	
	if (global.challenges == 1) {
		timing_activate_object(o_restartchallengebutton)
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
