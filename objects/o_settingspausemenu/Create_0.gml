depth = -100
instance_create(x, y, o_info)

// Delete Android Buttons while in settings
if os_type = os_android || os_type = os_gxgames {
	instance_destroy(o_buttoninteractandroid)
	instance_destroy(o_buttonjumpandroid)
	instance_destroy(o_buttonpauseandroid)
	instance_destroy(o_buttonleftandroid)
	instance_destroy(o_buttonrightandroid)
	instance_destroy(o_buttonrestartandroid)
}

// Spawn all data-driven settings buttons
scr_spawn_settings_buttons()

instance_create(x, y, o_animatedtext)
with (o_animatedtext) {
	texty = 40
	text = loc("ADJUST_OPTIONS");
}

alarm[0] = 2

instance_deactivate_object(o_settings)
instance_deactivate_object(o_givefeedback)
instance_deactivate_object(o_pausescreen)

if global.challenges = 1 {
	instance_deactivate_object(o_restartchallengebutton)
}
